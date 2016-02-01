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
create procedure spUpdateTrainingPlan(in vTrainingPlanName varchar(128),
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
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat('PROFILEid = <', vProfileId, '> : ', 
                                                          'NAME = <', vTrainingPlanName, '> : ',
                                                          'ID = <', ObjectId, '>');
    
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
    call spGetIdForTrainingPlan (vTrainingPlanName, vProfileId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - UPDATE RESULTS IN NO CHANGE';
        
    elseif (ObjectId is NOT NULL) then
        set SprocComment = concat('Update to [', SignificantFields, '] where ID = ', ObjectId, ' Transaction: UPDATE');
        
        -- Update ..
        update TRAINING_PLAN
           set 
               DATE_REGISTERED = current_timestamp(3),
               NAME = vTrainingPlanName
         where
               ID = ObjectId;
    
        -- Verify ..
        call spGetIdForTrainingPlan (vTrainingPlanName, vProfileId, localObjectId, ReturnCode);
        if (ObjectId = localObjectId) then
          set tStatus = 'SUCCESS';
        else
          set tStatus = 'FAILURE';
        end if;
    else
        set tStatus = 'IGNORED';
    end if;
    
    -- Log ..
    set SprocComment = concat('Update OBJECT to [', SignificantFields, '] where ID = ', ifNull(ObjectId, 'NULL'), ':  ', tStatus);
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
