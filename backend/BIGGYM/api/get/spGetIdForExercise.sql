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

    -- Prepare for valued fields or null or if defined as NOT NULL fields, blanks (when set to NULL) ..
    set @getIdWhereClause = concat('(NAME = ''', ifNull(concat(vExerciseName, ''''), 'NULL'' or NAME is NULL or length(NAME) = 0'), ')', 
                                   ' and ',
                                   '(BODY_PART = ''', ifNull(concat(vBodyPartName, ''''), 'NULL'' or BODY_PART is NULL or length(BODY_PART) = 0'), ')');
    -- Get ..
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
    
end$$
delimiter ;
