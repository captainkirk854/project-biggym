/*
Name       : spCreateTrainingPlanDefinition
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN_DEFINITION
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spGetIdForTrainingPlanDefinition
*/

use BIGGYM;

drop procedure if exists spCreateTrainingPlanDefinition;
delimiter $$
create procedure spCreateTrainingPlanDefinition(in vExerciseId mediumint unsigned,
                                                in vPlanId mediumint unsigned,
											   out ObjectId mediumint unsigned,
                                               out ReturnCode int,
                                               out ErrorCode int,
                                               out ErrorState int,
                                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    declare SprocName varchar(128) default 'spCreateTrainingPlanDefinition';
    
    declare vNew_ExerciseWeek tinyint unsigned default 1;
	declare vNew_ExerciseDay tinyint unsigned default NULL;
    declare vNew_ExerciseOrdinality tinyint unsigned default NULL;
    
    declare SignificantFields varchar(256) default concat('NONE');
    declare WhereCondition varchar(256) default concat('where PLANid = ', vPlanId, ' and EXERCISEid = ', vExerciseId, '');
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

    -- Attempt Training Plan Definition update ..
    call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseId, vNew_ExerciseWeek, vNew_ExerciseDay, vNew_ExerciseOrdinality, ObjectId, ReturnCode);
	if (ObjectId is NULL) then    
		insert into 
				TRAINING_PLAN_DEFINITION
				(
				 PLANId,
				 EXERCISEid
				)
				values
				(
				 vPlanId,
				 vExerciseId
				);
        set tStatus = 'SUCCESS';
        call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseId, vNew_ExerciseWeek, vNew_ExerciseDay, vNew_ExerciseOrdinality, ObjectId, ReturnCode);
	else
		set tStatus = 'FIELD VALUE(S) ALREADY PRESENT';
	end if;
    
    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(ObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

set @planId=5;
set @ExerciseId=4;
call spCreateTrainingPlanDefinition (@ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

*/
