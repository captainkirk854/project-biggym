/*
Name       : RegisterTrainingPlan
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
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spRegisterTrainingPlan;
delimiter $$
create procedure spRegisterTrainingPlan(in vTrainingPlanName varchar(128),
                                        in vProfileName varchar(32),
                                        in vFirstName varchar(32),
                                        in vLastName varchar(32),
                                        in vBirthDate date,
                                       out ObjectId smallint,
                                       out ReturnCode int,
                                       out ErrorCode int,
                                       out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN';
    declare vProfileId smallint default NULL;
    
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare CONTINUE handler for SQLEXCEPTION
        begin
          call spErrorHandler (ReturnCode, ErrorCode, ErrorMsg);
          call spDebugLogger (database(), ObjectName, ReturnCode, ErrorCode, ErrorMsg);
        end;
 
    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Error Handling --
    -- -------------------------------------------------------------------------

    -- Attempt pre-emptive profile registration ..
    call spRegisterProfile (vProfileName, 
                            vFirstName, 
                            vLastName, 
                            vBirthDate, 
                            vProfileId, 
                            returnCode, 
                            errorCode, 
                            errorMsg);
 
    -- Attempt TrainingPlan registration ..
    if (vProfileId is NOT NULL) then
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
    end if;
    
    -- Get its ID ..
    set @getIdWhereClause = concat('NAME = ''', vTrainingPlanName,  ''' and PROFILEid = ', vProfileId);
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode); 

end$$
delimiter ;


/*
Sample Usage:

call spRegisterTrainingPlan ('Get Bigger Workout', 'Faceman', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;

call spRegisterTrainingPlan ('Get Bigger Workout', 'Mr.T', 'Lawrence', 'Tureaud', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;

select * from TRAINING_PLAN order by DATE_REGISTERED asc;
*/
