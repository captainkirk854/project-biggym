/*
Name       : spGetIdForTrainingPlan
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN
            
            STORED PROCEDURE :
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spGetIdForTrainingPlan;
delimiter $$
create procedure spGetIdForTrainingPlan(in vTrainingPlanName varchar(128),
                                        in vProfileId mediumint unsigned,
                                       out ObjectId mediumint unsigned,
                                       out ReturnCode int)
begin

    -- Declare ..
       declare ObjectName varchar(128) default 'TRAINING_PLAN';
        
    -- Prepare ..
       set @getIdWhereClause = concat('NAME = ''', vTrainingPlanName,  ''' and PROFILEid = ', vProfileId);

    -- Get ..                                 
       call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode); 
    
end$$
delimiter ;


/*
Sample Usage:

call spGetIdForTrainingPlan ('Get Bigger Scam Workout', 11, @id, @returnCode);
select @id, @returnCode;
*/
