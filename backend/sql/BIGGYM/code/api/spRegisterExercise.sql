/*
Name       : spRegisterExercise
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spGetIdForExercise
*/

use BIGGYM;

drop procedure if exists spRegisterExercise;
delimiter $$
create procedure spRegisterExercise(in vExerciseName varchar(128),
                                    in vBodyPartName varchar(128),
                                   out ObjectId mediumint unsigned,  
                                   out ReturnCode int,
                                   out ErrorCode int,
                                   out ErrorState int,
                                   out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';
    declare SprocName varchar(128) default 'spRegisterExercise';
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat(vExerciseName, ': ', vBodyPartName);
    
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------  
    declare CONTINUE handler for SQLEXCEPTION
        begin        
           set SprocComment = concat('SEVERITY 1 EXCEPTION: ', SprocComment);
          call spErrorHandler (ReturnCode, ErrorCode, ErrorState, ErrorMsg);
          call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        end;

    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------
 
    -- Attempt exercise registration ..
    set SprocComment = concat('Searching for ObjectId [', SignificantFields, ']');
    call spGetIdForExercise (vExerciseName, vBodyPartName, ObjectId, ReturnCode);
    
    if (ObjectId is NULL) then
        set SprocComment = concat('ObjectId for [', SignificantFields, '] not found - Transaction required: INSERT');
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
        call spGetIdForExercise (vExerciseName, vBodyPartName, ObjectId, ReturnCode);
    else
        set SprocComment = concat('ObjectId for [', SignificantFields, '] already exists');
    end if;
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

call spRegisterExercise ('Pullups', 'Back', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;
*/
