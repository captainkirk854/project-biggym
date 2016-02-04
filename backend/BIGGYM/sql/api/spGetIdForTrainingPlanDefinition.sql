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
                                                  in vExerciseId mediumint unsigned,
                                                  in vExerciseWeek tinyint unsigned,
                                                  in vExerciseDay tinyint unsigned,
                                                  in vExerciseOrdinality mediumint unsigned,
                                                 out ObjectId mediumint unsigned,
                                                 out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    
    -- Prepare ..
    set @getIdWhereClause = concat(     ' PLANId = ', vPlanId,
                                    ' and EXERCISEid = ', vExerciseId,
                                    ' and (EXERCISE_WEEK = ', ifNull(vExerciseWeek, 'NULL or EXERCISE_WEEK is NULL'), ')',
                                    ' and (EXERCISE_DAY = ', ifNull(vExerciseDay, 'NULL or EXERCISE_DAY is NULL'), ')',
                                    ' and (EXERCISE_ORDINALITY = ', ifNull(vExerciseOrdinality, 'NULL or EXERCISE_ORDINALITY is NULL'), ')'
                                  );
    
    -- Get Plan Definition Id ..   
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;

/*
Sample Usage:

set @planId=5;
set @ExerciseId=4;
set @ExerciseWeek=1;
set @ExerciseDay=NULL;
set @ExerciseOrder=NULL;
call spGetIdForTrainingPlanDefinition (@planId, @ExerciseId, @ExerciseWeek, @ExerciseDay, @ExerciseOrder, @id, @returnCode);
select @id, @returnCode;
*/
