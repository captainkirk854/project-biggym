/*
Name       : spRegisterExercise
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spRegisterExercise;
delimiter $$
create procedure spRegisterExercise(in vExerciseName varchar(128),
                                    in vBodyPartName varchar(128),
                                   out ObjectId smallint,  
                                   out ReturnCode int,
                                   out ErrorCode int,
                                   out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';
    
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------  
    declare CONTINUE handler for SQLEXCEPTION
        begin
          call spErrorHandler (ReturnCode, ErrorCode, ErrorMsg);
          call spDebugLogger (database(), ObjectName, ReturnCode, ErrorCode, ErrorMsg);
        end;

    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------
 
    -- Attempt exercise registration ..
    insert into 
        EXERCISE
            (
             NAME,
             BODY_PART
            )
            values
            (
             vExerciseName,
             vBodyPartName
            );

    -- Get its ID ..
    set @getIdWhereClause = concat('NAME = ''', vExerciseName,  ''' and BODY_PART = ''', vBodyPartName, '''');
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
 
end$$
delimiter ;


/*
Sample Usage:

call spRegisterExercise ('Pullups', 'Back', @id, @returnCode, @errorCode, @errorMsg);
select  @id, @returnCode, @errorCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;
*/
