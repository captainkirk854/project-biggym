/*
Name       : spRegisterExercise
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
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
 
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------  
    declare CONTINUE handler for SQLEXCEPTION
        begin
          set @objectName = 'EXERCISE';
          call spErrorHandler (ReturnCode, ErrorCode, ErrorMsg);
          call spDebugLogger (database(), @objectName, ReturnCode, ErrorCode, ErrorMsg);
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

    -- Get ID ..
    set ObjectId = NULL;

    select 
        ID
      into
        ObjectId
      from 
        EXERCISE 
     where 
        NAME = vExerciseName 
       and 
        BODY_PART = vBodyPartName 
   limit 1;
      
    -- If ID found, reset ReturnCode to 0 ..
    if (ObjectId is NOT NULL and ReturnCode != 0) then
        set ReturnCode = 0;
    end if; 
 
end$$
delimiter ;


/*
Sample Usage:

call spRegisterExercise ('Pullups', 'Back', @id, @returnCode, @errorCode, @errorMsg);
select  @id, @returnCode, @errorCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;
*/
