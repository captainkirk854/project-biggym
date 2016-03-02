/*
Name       : spGetIdForExerciseFromTrainingPlanDefinitionId
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN_DEFINITION
            
            STORED PROCEDURE :
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spGetIdForExerciseFromTrainingPlanDefinitionId;
delimiter $$
create procedure spGetIdForExerciseFromTrainingPlanDefinitionId(in vExerciseId mediumint unsigned,
                                                             inout ObjectId mediumint unsigned,
                                                               out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    
    -- Prepare ..
    set @getIdWhereClause = concat(     ' exerciseId = ', vExerciseId,
                                    ' and Id = ', ObjectId
                                  );    
    -- Get ..   
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;