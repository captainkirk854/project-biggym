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
create procedure spGetIdForTrainingPlanDefinition(in vPlanId mediumint unsigned,
                                                  in vExerciseWeek tinyint unsigned,
                                                  in vExerciseDay tinyint unsigned,
                                                  in vExerciseOrdinality mediumint unsigned,
                                                  in vExerciseId mediumint unsigned,
                                                 out ObjectId mediumint unsigned,
                                                 out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    
    -- Get Plan Definition Id ..
    set @getIdWhereClause = concat(      ' PLANId = ', vPlanId,
                                    ' and (EXERCISE_WEEK = ', ifNull(vExerciseWeek, 'NULL or EXERCISE_WEEK is NULL'), ')',
                                    ' and (EXERCISE_DAY = ', ifNull(vExerciseDay, 'NULL or EXERCISE_DAY is NULL'), ')',
                                    ' and (EXERCISE_ORDINALITY = ', ifNull(vExerciseOrdinality, 'NULL or EXERCISE_ORDINALITY is NULL'), ')',
                                    ' and EXERCISEid = ', vExerciseId
                                  );
    
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;

/*
Sample Usage:

set @planId=5;
set @ExerciseWeek=NULL;
set @ExerciseDay=NULL;
set @ExerciseOrder=NULL;
set @ExerciseId=4;
call spGetIdForTrainingPlanDefinition (@planId, @ExerciseWeek, @ExerciseDay, @ExerciseOrder, @ExerciseId, @id, @returnCode);
select @id, @returnCode;
*/
