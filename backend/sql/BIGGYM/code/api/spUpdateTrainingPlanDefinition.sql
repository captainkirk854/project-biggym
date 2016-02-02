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
                - spDebugLogger 
                - spErrorHandler
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
    declare SprocName varchar(128) default 'spUpdateTrainingPlanDefinition';
    declare SignificantFields varchar(256) default concat('EXERCISE_WEEK = <', ifNull(vUpdatable_ExerciseWeek, 'NULL'), '> ', 'EXERCISE_DAY = <', ifNull(vUpdatable_ExerciseDay, 'NULL'), '> ', 'EXERCISE_ORDINALITY = <', ifNull(vUpdatable_ExerciseOrdinality, 'NULL'), '> ',  'EXERCISEid = <', vUpdatable_ExerciseId, '>');
    declare WhereCondition varchar(256) default concat('where ID = ', ifNull(ObjectId, 'NULL'), ' AND PLANid = ', vPlanId);
    declare SprocComment varchar(512) default concat('update object field list [', SignificantFields, '] ', WhereCondition);  
    
    declare localObjectId mediumint unsigned;
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
    call spGetIdForTrainingPlanDefinition (vPlanId, vUpdatable_ExerciseWeek, vUpdatable_ExerciseDay, vUpdatable_ExerciseOrdinality, vUpdatable_ExerciseId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - NO CHANGE FROM CURRENT';
        
    elseif (ObjectId is NOT NULL) then
        
        -- Update ..
        update TRAINING_PLAN_DEFINITION
           set 
               DATE_REGISTERED = current_timestamp(3),
               EXERCISE_WEEK = vUpdatable_ExerciseWeek,
               EXERCISE_DAY = vUpdatable_ExerciseDay,
               EXERCISE_ORDINALITY = vUpdatable_ExerciseOrdinality,
               EXERCISEid = vUpdatable_ExerciseId
         where
               ID = ObjectId
           and
               PLANid = vPlanId;
    
        -- Verify ..
        call spGetIdForTrainingPlanDefinition (vPlanId, vUpdatable_ExerciseWeek, vUpdatable_ExerciseDay, vUpdatable_ExerciseOrdinality, vUpdatable_ExerciseId, localObjectId, ReturnCode);
        if (ObjectId = localObjectId) then
          set tStatus = 'SUCCESS';
        else
          set tStatus = 'FAILURE';
        end if;
    else
        set tStatus = 'IGNORED';
    end if;
    
    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(localObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

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
