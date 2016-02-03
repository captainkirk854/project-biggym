/*
Name       : spCreateExercise
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForExercise
*/

use BIGGYM;

drop procedure if exists spCreateExercise;
delimiter $$
create procedure spCreateExercise(in vNew_ExerciseName varchar(128),
                                  in vNew_BodyPartName varchar(128),
                                 out ObjectId mediumint unsigned,  
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';
    declare SpName varchar(128) default 'spCreateExercise';
    declare SignificantFields varchar(256) default concat('NAME=', vNew_ExerciseName, ',BODY_PART=', vNew_BodyPartName);
    declare ReferenceFields varchar(256) default concat('na');
    declare TransactionType varchar(16) default 'insert';
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default '-';
 
    declare EXIT handler for SQLEXCEPTION
    begin
      set @severity = 1;
      call spActionOnException (ObjectName, SpName, @severity, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    end;
    
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    
    -- Only "good" string input is allowed ..
    if(strisgood(vNew_ExerciseName) and strisgood(vNew_BodyPartName)) then
 
        -- Attempt create ..
        call spGetIdForExercise (vNew_ExerciseName, vNew_BodyPartName, ObjectId, ReturnCode);
        if (ObjectId is NULL) then
            insert into 
                    EXERCISE
                    (
                     NAME,
                     BODY_PART
                    )
                    values
                    (
                     vNew_ExerciseName,
                     vNew_BodyPartName
                    );
            -- success ..
            set tStatus = 0;
            call spGetIdForExercise (vNew_ExerciseName, vNew_BodyPartName, ObjectId, ReturnCode);
        else
            -- already exists ..
            set tStatus = 1;
        end if;
    else
        -- illegal characters found ..
        set tStatus = -1;
    end if;

    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    
end$$
delimiter ;


/*
Sample Usage:

call spCreateExercise ('Pullups', 'Back', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;


call spCreateExercise ('!!!!***', 'Back', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;

call spCreateExercise ('!!!!***pullup', 'Back', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;
*/
