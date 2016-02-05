/*
Name       : spGetIdForExercise
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spGetIdForExercise;
delimiter $$
create procedure spGetIdForExercise(in vExerciseName varchar(128),
                                    in vBodyPartName varchar(128),
                                   out ObjectId mediumint unsigned,
                                   out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';

    -- Prepare ..
    set @getIdWhereClause = concat('NAME = ''', vExerciseName,  ''' and BODY_PART = ''', vBodyPartName, '''');
    
    -- Get ..
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;


/*
Sample Usage:

call spGetIdForExercise ('Dips','Arms', @id, @returnCode);
select @id, @returnCode;
*/
