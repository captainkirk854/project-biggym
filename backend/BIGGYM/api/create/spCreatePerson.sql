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
                                in vNew_Gender char(1),
                                in vNew_BodyHeight double,
                               out ObjectId mediumint unsigned,
                               out ReturnCode int,
                               out ErrorCode int,
                               out ErrorState int,
                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PERSON';
    declare SpName varchar(128) default 'spCreatePerson';
    declare SignificantFields varchar(512) default concat('FIRST_NAME=', saynull(vNew_FirstName), 
                                                          ',LAST_NAME=', saynull(vNew_LastName), 
                                                          ',BIRTH_DATE=', saynull(vNew_BirthDate),
                                                          ',GENDER=', saynull(vNew_Gender),
                                                          ',HEIGHT=', saynull(vNew_BodyHeight));
    declare ReferenceFields varchar(512) default concat('na');
    declare TransactionType varchar(16) default 'insert';
    
    declare SpComment varchar(1024);
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
    
        -- Check if date uses valid format (YY-mm-dd) ..
        if (date(vNew_BirthDate) is NOT NULL and (vNew_BirthDate != '0000-00-00')) then
    
            -- Attempt create ..
            call spGetIdForPerson (vNew_FirstName, vNew_LastName, vNew_BirthDate, ObjectId, ReturnCode);
            if (ObjectId is NULL) then
                insert into 
                        PERSON
                        (
                         FIRST_NAME,
                         LAST_NAME,
                         BIRTH_DATE,
                         gender,
                         body_height
                        )
                        values
                        (
                         vNew_FirstName,
                         vNew_LastName,
                         vNew_BirthDate,
                         vNew_Gender,
                         vNew_BodyHeight
                        );
                -- success ..
                set tStatus = 0;
                call spGetIdForPerson (vNew_FirstName, vNew_LastName, vNew_BirthDate, ObjectId, ReturnCode);
            else
                -- already exists ..
                set tStatus = 1;
            end if;
        else
            -- invalid date format used ..
            set tStatus = -6;
        end if;
    else
        -- illegal or null characters found ..
        set tStatus = -1;
    end if;

    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
 
end$$
delimiter ;
