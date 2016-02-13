/*
Name       : spUpdateTrainingPlan
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForTrainingPlan
*/

use BIGGYM;

drop procedure if exists spUpdateTrainingPlan;
delimiter $$
create procedure spUpdateTrainingPlan(in vUpdatable_TrainingPlanName varchar(128),
                                      in vProfileId mediumint unsigned,
                                      in ObjectId mediumint unsigned,
                                     out ReturnCode int,
                                     out ErrorCode int,
                                     out ErrorState int,
                                     out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN';
    declare SpName varchar(128) default 'spUpdateTrainingPlan';
    declare SignificantFields varchar(256) default concat('NAME=', saynull(vUpdatable_TrainingPlanName));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId), 
                                                        ',PROFILEid=', saynull(vProfileId));
    declare TransactionType varchar(16) default 'update';
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default '-';
    declare localObjectId mediumint unsigned;    
    
    declare EXIT handler for SQLEXCEPTION
    begin
      set @severity = 1;
      call spActionOnException (ObjectName, SpName, @severity, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    end;
    
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    
    -- Attempt update ..
    call spGetIdForTrainingPlan (vUpdatable_TrainingPlanName, vProfileId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        -- no update required ..
        set tStatus = 2;
        
    elseif (ObjectId is NOT NULL) then
    
        -- Update ..
        update TRAINING_PLAN
           set 
               DATE_REGISTERED = current_timestamp(3),
               NAME = vUpdatable_TrainingPlanName
         where
               ID = ObjectId
           and
               PROFILEid = vProfileId;
    
        -- Verify ..
        call spGetIdForTrainingPlan (vUpdatable_TrainingPlanName, vProfileId, localObjectId, ReturnCode);
        if (ObjectId = localObjectId) then
            -- success ..
            set tStatus = 0;
        else
            -- unexpected multiple occurrence ..
            set tStatus = -2;
        end if;
    else
        -- transaction ignored ..
        set tStatus = -3;
    end if;
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    
end$$
delimiter ;


/*
Sample Usage:
set @profileId=11;
set @trainingPlanId=6;
call spUpdateTrainingPlan ('Get Bigger Scam Workout', @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @profileId=11;
set @trainingPlanId=6;
call spUpdateTrainingPlan ('Get Bigger Workout', @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @profileId=11;
set @trainingPlanId=66;
call spUpdateTrainingPlan ('Get Bigger Workout', @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg;
*/
