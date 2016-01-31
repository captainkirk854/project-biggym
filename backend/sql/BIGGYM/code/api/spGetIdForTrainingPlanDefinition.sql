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
                                                  in vExerciseId smallint,
                                                 out ObjectId smallint,
                                                 out ReturnCode int)

begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    
    -- Get Plan Definition Id ..
    set @getIdWhereClause = concat('PLANId = ', vPlanId, ' and EXERCISEid = ', vExerciseId);
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;

/*
Sample Usage:

call spGetIdForTrainingPlanDefinition (5, 4, @id, @returnCode);
select @id, @returnCode;
*/
