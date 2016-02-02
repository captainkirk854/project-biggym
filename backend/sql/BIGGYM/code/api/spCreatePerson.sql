/*
Name       : spCreatePerson
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
    declare SprocName varchar(128) default 'spCreatePerson';
    
    declare SignificantFields varchar(256) default concat('FIRST_NAME = <', vNew_FirstName, '> ', 'LAST_NAME = <', vNew_LastName, '> ', 'BIRTH_DATE = <', vNew_BirthDate, '>');
    declare ReferenceObjects varchar(256) default concat(' NONE ');
    declare SprocComment varchar(512) default concat('insert into object field list [', SignificantFields, '] ', 'using reference(s) [', ReferenceObjects, ']');
    
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
    
    -- Clean character input ..
    set vNew_FirstName = strcln(vNew_FirstName);
    set vNew_LastName = strcln(vNew_LastName);
    set vNew_BirthDate = strcln(vNew_BirthDate);
 
    -- Check for valid input ..
    if(length(vNew_FirstName)*length(vNew_LastName)*length(vNew_BirthDate) != 0) then
 
        -- Attempt person registration ..
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
            set tStatus = 'SUCCESS';
            call spGetIdForPerson (vNew_FirstName, vNew_LastName, vNew_BirthDate, ObjectId, ReturnCode);
        else
            set tStatus = 'FIELD VALUE(S) ALREADY PRESENT';
        end if;
    else
        set tStatus = 'ONLY ILLEGAL CHARACTERS IN ONE OR MORE FIELD VALUE(S)';
        set ReturnCode = -1;
    end if;

    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(ObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
 
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
