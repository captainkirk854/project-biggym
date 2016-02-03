/*
Name       : spUpdateTrainingPlanDefinition
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN_DEFINITION
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForTrainingPlanDefinition
*/

use BIGGYM;

drop procedure if exists spUpdateTrainingPlanDefinition;
delimiter $$
create procedure spUpdateTrainingPlanDefinition(in vUpdatable_ExerciseWeek tinyint unsigned,
                                                in vUpdatable_ExerciseDay tinyint unsigned,
                                                in vUpdatable_ExerciseOrdinality tinyint unsigned,
                                                in vUpdatable_ExerciseId mediumint unsigned,
                                                in vPlanId mediumint unsigned,
                                                in ObjectId mediumint unsigned,
                                               out ReturnCode int,
                                               out ErrorCode int,
                                               out ErrorState int,
                                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    declare SpName varchar(128) default 'spUpdateTrainingPlanDefinition';
    declare SignificantFields varchar(256) default concat('EXERCISE_WEEK=', ifNull(vUpdatable_ExerciseWeek, 'NULL'), 
                                                          ',EXERCISE_DAY=', ifNull(vUpdatable_ExerciseDay, 'NULL'), 
                                                          ',EXERCISE_ORDINALITY=', ifNull(vUpdatable_ExerciseOrdinality, 'NULL'), 
                                                          ',EXERCISEid=', vUpdatable_ExerciseId);
    declare ReferenceFields varchar(256) default concat('ID=', ifNull(ObjectId, 'NULL'), ',PLANid=', vPlanId);
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
    call spGetIdForTrainingPlanDefinition (vPlanId, vUpdatable_ExerciseId, vUpdatable_ExerciseWeek, vUpdatable_ExerciseDay, vUpdatable_ExerciseOrdinality, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        -- no update required ..
        set tStatus = 2;
        
    elseif (ObjectId is NOT NULL) then
        
        -- Update ..
        update TRAINING_PLAN_DEFINITION
           set 
               DATE_REGISTERED = current_timestamp(3),
               EXERCISEid = vUpdatable_ExerciseId,
               EXERCISE_WEEK = vUpdatable_ExerciseWeek,
               EXERCISE_DAY = vUpdatable_ExerciseDay,
               EXERCISE_ORDINALITY = vUpdatable_ExerciseOrdinality
         where
               ID = ObjectId
           and
               PLANid = vPlanId;
    
        -- Verify ..
        call spGetIdForTrainingPlanDefinition (vPlanId, vUpdatable_ExerciseId, vUpdatable_ExerciseWeek, vUpdatable_ExerciseDay, vUpdatable_ExerciseOrdinality, localObjectId, ReturnCode);
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

set @planDefinitionId = 3;
set @planId=5;
set @exerciseWeek=NULL;
set @exerciseDay=NULL;
set @ExerciseOrder=NULL;
set @ExerciseId=4;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 3;
set @planId=5;
set @exerciseWeek=NULL;
set @exerciseDay=1;
set @ExerciseOrder=NULL;
set @ExerciseId=4;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 3;
set @planId=5;
set @exerciseWeek=NULL;
set @exerciseDay=1;
set @ExerciseOrder=1;
set @ExerciseId=4;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 3;
set @planId=5;
set @exerciseWeek=NULL;
set @exerciseDay=1;
set @ExerciseOrder=1;
set @ExerciseId=5;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;


set @planDefinitionId = 2;
set @planId=2;
set @exerciseWeek=NULL;
set @exerciseDay=1;
set @ExerciseOrder=1;
set @ExerciseId=1;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 2;
set @planId=2;
set @exerciseWeek=NULL;
set @exerciseDay=1;
set @ExerciseOrder=1;
set @ExerciseId=3;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 1;
set @planId=2;
set @exerciseWeek=NULL;
set @exerciseDay=1;
set @ExerciseOrder=1;
set @ExerciseId=3;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 1;
set @planId=2;
set @exerciseWeek=2;
set @exerciseDay=1;
set @ExerciseOrder=2;
set @ExerciseId=5;
call spUpdateTrainingPlanDefinition (@exerciseWeek, @exerciseDay, @ExerciseOrder, @ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;
*/
