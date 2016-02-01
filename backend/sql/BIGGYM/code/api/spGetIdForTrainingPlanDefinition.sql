/*
Name       : spGetIdForTrainingPlanDefinition
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN_DEFINITION
            
            STORED PROCEDURE :
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spGetIdForTrainingPlanDefinition;
delimiter $$
create procedure spGetIdForTrainingPlanDefinition(in vPlanId smallint,
                                                  in vPlanDay smallint,
                                                  in vExerciseOrdinality smallint,
                                                  in vExerciseId smallint,
                                                 out ObjectId smallint,
                                                 out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    
    -- Get Plan Definition Id ..
    set @getIdWhereClause = concat(      ' PLANId = ', vPlanId,
                                    ' and (PLAN_DAY = ', ifNull(vPlanDay, 'NULL or PLAN_DAY is NULL'), ')',
                                    ' and (EXERCISE_ORDINALITY = ', ifNull(vExerciseOrdinality, 'NULL or EXERCISE_ORDINALITY is NULL'), ')',
                                    ' and EXERCISEid = ', vExerciseId
                                  );
    
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;

/*
Sample Usage:

set @planId=5;
set @planDay=NULL;
set @ExerciseOrder=NULL;
set @ExerciseId=4;
call spGetIdForTrainingPlanDefinition (@planId, @planDay, @ExerciseOrder, @ExerciseId, @id, @returnCode);
select @id, @returnCode;
*/
