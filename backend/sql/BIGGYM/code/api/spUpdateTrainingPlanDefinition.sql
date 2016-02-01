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
create procedure spUpdateTrainingPlanDefinition(in vPlanId smallint,
                                                in vPlanDay smallint,
                                                in vExerciseOrdinality smallint,
                                                in vExerciseId smallint,
                                                in ObjectId smallint,
                                               out ReturnCode int,
                                               out ErrorCode int,
                                               out ErrorState int,
                                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    declare SprocName varchar(128) default 'spUpdateTrainingPlanDefinition';
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat('PLANid = <', vPlanId, '> : ', 
                                                          'PLAN_DAY = <', ifNull(vPlanDay, 'NULL'), '> : ',
                                                          'EXERCISE_ORDINALITY = <', ifNull(vExerciseOrdinality, 'NULL'), '> : ',
                                                          'EXERCISEid = <', vExerciseId, '> : ',
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

    -- Attempt Training Plan Definition update ..
    call spGetIdForTrainingPlanDefinition (vPlanId, vPlanDay, vExerciseOrdinality, vExerciseId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - UPDATE RESULTS IN NO CHANGE';
        
    elseif (ObjectId is NOT NULL) then
        set SprocComment = concat('Update to [', SignificantFields, '] where ID = ', ObjectId, ' Transaction: UPDATE');
        
        -- Update ..
        update TRAINING_PLAN_DEFINITION
           set 
               DATE_REGISTERED = current_timestamp(3),
               PLAN_DAY = vPlanDay,
               EXERCISE_ORDINALITY = vExerciseOrdinality,
               EXERCISEid = vExerciseId
         where
               ID = ObjectId;
    
        -- Verify ..
        call spGetIdForTrainingPlanDefinition (vPlanId, vPlanDay, vExerciseOrdinality, vExerciseId, localObjectId, ReturnCode);
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

set @planDefinitionId = 3;
set @planId=5;
set @planDay=NULL;
set @ExerciseOrder=NULL;
set @ExerciseId=4;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 3;
set @planId=5;
set @planDay=1;
set @ExerciseOrder=NULL;
set @ExerciseId=4;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 3;
set @planId=5;
set @planDay=1;
set @ExerciseOrder=1;
set @ExerciseId=4;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 3;
set @planId=5;
set @planDay=1;
set @ExerciseOrder=1;
set @ExerciseId=5;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;


set @planDefinitionId = 2;
set @planId=2;
set @planDay=1;
set @ExerciseOrder=1;
set @ExerciseId=1;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 2;
set @planId=2;
set @planDay=1;
set @ExerciseOrder=1;
set @ExerciseId=3;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 1;
set @planId=2;
set @planDay=1;
set @ExerciseOrder=1;
set @ExerciseId=3;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planDefinitionId = 1;
set @planId=2;
set @planDay=1;
set @ExerciseOrder=2;
set @ExerciseId=4;
call spUpdateTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;
*/
