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
create procedure spRegisterTrainingPlan(in vTrainingPlanName varchar(128),
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
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat(vFirstName, ': ', vLastName, ': ', vBirthDate, ': ', vProfileName, ': ', vTrainingPlanName);
    declare vProfileId mediumint unsigned default NULL;
    
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare CONTINUE handler for SQLEXCEPTION
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

        set SprocComment = concat('Searching for ObjectId [', SignificantFields, ']');
        call spGetIdForTrainingPlan (vTrainingPlanName, vProfileId, ObjectId, ReturnCode);

        if (ObjectId is NULL) then
            set SprocComment = concat('ObjectId for [', SignificantFields, '] not found - Transaction required: INSERT');
            insert into 
                    TRAINING_PLAN
                    (
                     NAME,
                     PROFILEid
                    )
                    values
                    (
                     vTrainingPlanName,
                     vProfileId
                    );
            call spGetIdForTrainingPlan (vTrainingPlanName, vProfileId, ObjectId, ReturnCode);
        else
            set SprocComment = concat('ObjectId for [', SignificantFields, '] already exists');
        end if;

    end if;
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
