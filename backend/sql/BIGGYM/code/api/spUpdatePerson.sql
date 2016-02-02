/*
Name       : spUpdatePerson
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
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
    declare SprocName varchar(128) default 'spUpdatePerson';
    
    declare SignificantFields varchar(256) default concat('FIRST_NAME = <', vUpdatable_FirstName, '> ', 'LAST_NAME = <', vUpdatable_LastName, '> ', 'BIRTH_DATE = <', vUpdatable_BirthDate, '>');
    declare WhereCondition varchar(256) default concat('where ID = ', ifNull(ObjectId, 'NULL'));
    declare SprocComment varchar(512) default concat('update object field list [', SignificantFields, '] ', WhereCondition);
    
    declare localObjectId mediumint unsigned;
    declare tStatus varchar(64) default '-';
 
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------
    declare EXIT handler for SQLEXCEPTION
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
 
    -- Attempt person update ..
    call spGetIdForPerson (vUpdatable_FirstName, vUpdatable_LastName, vUpdatable_BirthDate, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - NO CHANGE FROM CURRENT';
        
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
          set tStatus = 'SUCCESS';
        else
          set tStatus = 'FAILURE';
        end if;
    else
        set tStatus = 'IGNORED';
    end if;
    
    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(localObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);    

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
