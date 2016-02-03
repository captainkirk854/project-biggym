/*
Name       : spCreatePerson
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForPerson
*/

use BIGGYM;

drop procedure if exists spCreatePerson;
delimiter $$
create procedure spCreatePerson(in vNew_FirstName varchar(32),
                                in vNew_LastName varchar(32),
                                in vNew_BirthDate date,
                               out ObjectId mediumint unsigned,
                               out ReturnCode int,
                               out ErrorCode int,
                               out ErrorState int,
                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PERSON';
    declare SpName varchar(128) default 'spCreatePerson';
    declare SignificantFields varchar(256) default concat('FIRST_NAME=', vNew_FirstName, ',LAST_NAME =', vNew_LastName, ',BIRTH_DATE =', vNew_BirthDate);
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
    if(strisgood(vNew_FirstName) and strisgood(vNew_LastName) and strisgood(vNew_BirthDate)) then
    
        -- Attempt create ..
        call spGetIdForPerson (vNew_FirstName, vNew_LastName, vNew_BirthDate, ObjectId, ReturnCode);
        if (ObjectId is NULL) then
            insert into 
                    PERSON
                    (
                     FIRST_NAME,
                     LAST_NAME,
                     BIRTH_DATE
                    )
                    values
                    (
                     vNew_FirstName,
                     vNew_LastName,
                     vNew_BirthDate
                    );
            -- success ..
            set tStatus = 0;
            call spGetIdForPerson (vNew_FirstName, vNew_LastName, vNew_BirthDate, ObjectId, ReturnCode);
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

call spCreatePerson ('Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from PERSON order by DATE_REGISTERED asc;

call spCreatePerson ('Dirk!!!%%', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from PERSON order by DATE_REGISTERED asc;
*/
