/*
Name       : spRegisterTrainingPlan
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spRegisterProfile
                - spGetIdForTrainingPlan
*/

use BIGGYM;

drop procedure if exists spRegisterTrainingPlan;
delimiter $$
create procedure spRegisterTrainingPlan(in vNew_TrainingPlanName varchar(128),
                                        in vProfileName varchar(32),
                                        in vFirstName varchar(32),
                                        in vLastName varchar(32),
                                        in vBirthDate date,
                                       out ObjectId mediumint unsigned,
                                       out ReturnCode int,
                                       out ErrorCode int,
                                       out ErrorState int,
                                       out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN';
    declare SprocName varchar(128) default 'spRegisterTrainingPlan';
    declare vProfileId mediumint unsigned default NULL;    
    
    declare SignificantFields varchar(256) default concat('NAME = <', vNew_TrainingPlanName, '>');
    declare ReferenceObjects varchar(256) default concat(' PROFILEId(', 'NAME = <', vProfileName, '>) and ' ,'PERSONid(', 'FIRST_NAME = <', vFirstName, '> ', 'LAST_NAME = <', vLastName, '> ', 'BIRTH_DATE = <', vBirthDate, '>)');
    declare SprocComment varchar(512) default concat('insert into object field list [', SignificantFields, '] ', 'using reference(s) [', ReferenceObjects, ']');
    
    declare tStatus varchar(64) default '-';   
    
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare EXIT handler for SQLEXCEPTION
        begin
           set SprocComment = concat('SEVERITY 1 EXCEPTION: ', SprocComment);
          call spErrorHandler (ReturnCode, ErrorCode, ErrorState, ErrorMsg);
          call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        end;
 
    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Error Handling --
    -- -------------------------------------------------------------------------
    
    -- Clean character input ..
    set vNew_TrainingPlanName = strcln(vNew_TrainingPlanName);

    -- Check for valid input ..
    if(length(vNew_TrainingPlanName) != 0) then

        -- Attempt pre-emptive profile registration cascade ..
        call spRegisterProfile (vProfileName, 
                                vFirstName, 
                                vLastName, 
                                vBirthDate, 
                                vProfileId, 
                                ReturnCode, 
                                ErrorCode,
                                ErrorState,
                                ErrorMsg);
     
        -- Attempt TrainingPlan registration ..
        if (vProfileId is NOT NULL) then
            call spGetIdForTrainingPlan (vNew_TrainingPlanName, vProfileId, ObjectId, ReturnCode);
            if (ObjectId is NULL) then
                insert into 
                        TRAINING_PLAN
                        (
                         NAME,
                         PROFILEid
                        )
                        values
                        (
                         vNew_TrainingPlanName,
                         vProfileId
                        );
                set tStatus = 'SUCCESS';
                call spGetIdForTrainingPlan (vNew_TrainingPlanName, vProfileId, ObjectId, ReturnCode);
            else
                set tStatus = 'FIELD VALUE(S) ALREADY PRESENT';
            end if;
        else
            set tStatus = 'CANNOT FIND REFERENCE OBJECT(S)';
        end if;
    else
        set tStatus = 'ONLY ILLEGAL CHARACTERS IN ONE OR MORE FIELD VALUE(S)';
        set ReturnCode = -1;
    end if;
 
    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(ObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg); 
    
end$$
delimiter ;


/*
Sample Usage:

call spRegisterTrainingPlan ('Get Bigger Workout', 'Faceman', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;

call spRegisterTrainingPlan ('Get Bigger Workout', 'Mr.T', 'Lawrence', 'Tureaud', '1952-05-21', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;

select * from TRAINING_PLAN order by DATE_REGISTERED asc;
*/
