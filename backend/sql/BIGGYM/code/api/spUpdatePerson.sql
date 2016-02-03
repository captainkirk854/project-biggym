/*
Name       : spUpdatePerson
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

drop procedure if exists spUpdatePerson;
delimiter $$
create procedure spUpdatePerson(in vUpdatable_FirstName varchar(32),
                                in vUpdatable_LastName varchar(32),
                                in vUpdatable_BirthDate date,
                                in ObjectId mediumint unsigned,
                               out ReturnCode int,
                               out ErrorCode int,
                               out ErrorState int,
                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PERSON';
    declare SpName varchar(128) default 'spUpdatePerson';
    declare SignificantFields varchar(256) default concat('FIRST_NAME=', vUpdatable_FirstName, ',LAST_NAME =', vUpdatable_LastName, ',BIRTH_DATE =', vUpdatable_BirthDate);
    declare ReferenceFields varchar(256) default concat('ID=', ifNull(ObjectId, 'NULL'));
    declare TransactionType varchar(16) default 'update';
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default '-';
    declare localObjectId mediumint unsigned;
    
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
    
    -- Attempt update ..
    call spGetIdForPerson (vUpdatable_FirstName, vUpdatable_LastName, vUpdatable_BirthDate, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        -- no update required ..
        set tStatus = 2;
        
    elseif (ObjectId is NOT NULL) then
        
        -- Update ..
        update PERSON
           set 
               DATE_REGISTERED = current_timestamp(3),
               FIRST_NAME = vUpdatable_FirstName,
               LAST_NAME = vUpdatable_LastName,
               BIRTH_DATE = vUpdatable_BirthDate
         where
               ID = ObjectId;
    
        -- Verify ..
        call spGetIdForPerson (vUpdatable_FirstName, vUpdatable_LastName, vUpdatable_BirthDate, localObjectId, ReturnCode);
        if (ObjectId = localObjectId) then
            -- success ..
            set tStatus = 0;
        else
            -- unexpected multiple occurrence ..
            set tStatus = -2;
        end if;
    else
        -- transaction ignored ..
        set tStatus = -3;
    end if;
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);   

end$$
delimiter ;


/*
Sample Usage:

set @personId=10;
call spUpdatePerson ('Dirk', 'Benedict', '1945-03-01', @personId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @personId=11;
call spUpdatePerson ('Dirk', 'Benedict', '1945-03-01', @personId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @personId=NULL;
call spUpdatePerson ('Dirk', 'Benedict', '1945-03-01', @personId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @personId=10;
call spUpdatePerson ('Dirkus', 'Benedictus', '1945-03-01', @personId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @returnCode, @errorCode, @stateCode, @errorMsg;
*/
