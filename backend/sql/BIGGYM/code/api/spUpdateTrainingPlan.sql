/*
Name       : spUpdateTrainingPlan
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spGetIdForTrainingPlan
*/

use BIGGYM;

drop procedure if exists spUpdateTrainingPlan;
delimiter $$
create procedure spUpdateTrainingPlan(in vUpdatable_TrainingPlanName varchar(128),
                                      in vProfileId smallint,
                                      in ObjectId smallint,
                                     out ReturnCode int,
                                     out ErrorCode int,
                                     out ErrorState int,
                                     out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN';
    declare SprocName varchar(128) default 'spUpdateTrainingPlan';
    
 	declare SignificantFields varchar(256) default concat('NAME = <', vUpdatable_TrainingPlanName, '>');
	declare WhereCondition varchar(256) default concat('WHERE ID = ', ifNull(ObjectId, 'NULL'), ' AND PROFILEid = ', vProfileId);
    declare SprocComment varchar(512) default concat('UPDATE OBJECT FIELD LIST [', SignificantFields, '] ', WhereCondition);       
    
    declare localObjectId smallint;
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

    -- Attempt Training Plan update ..
    call spGetIdForTrainingPlan (vUpdatable_TrainingPlanName, vProfileId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - NO CHANGE FROM CURRENT';
        
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
          set tStatus = 'SUCCESS';
        else
          set tStatus = 'FAILURE';
        end if;
    else
        set tStatus = 'IGNORED';
    end if;
    
    -- Log ..
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    
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
