/*
Name       : spCreateTrainingPlan
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

drop procedure if exists spCreateTrainingPlan;
delimiter $$
create procedure spCreateTrainingPlan(in vNew_TrainingPlanName varchar(128),
                                      in vProfileId mediumint unsigned,
									 out ObjectId mediumint unsigned,
                                     out ReturnCode int,
                                     out ErrorCode int,
                                     out ErrorState int,
                                     out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN';
    declare SprocName varchar(128) default 'spCreateTrainingPlan';
    
    declare SignificantFields varchar(256) default concat('NAME = <', vNew_TrainingPlanName, '>');
    declare WhereCondition varchar(256) default concat('where PROFILEid = ', vProfileId);
    declare SprocComment varchar(512) default concat('insert into object field list [', SignificantFields, '] ', WhereCondition);
    
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

		-- Attempt Training Plan registration ..
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
set @profileId=11;
call spCreateTrainingPlan ('Get Bigger Scam Workout', @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @profileId=11;
call spCreateTrainingPlan ('Get Bigger Workout', @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @profileId=12;
call spCreateTrainingPlan ('Get Bigger Workout', @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @profileId, @trainingPlanId, @returnCode, @errorCode, @stateCode, @errorMsg;
*/
