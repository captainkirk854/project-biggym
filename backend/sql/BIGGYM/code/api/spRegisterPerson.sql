/*
Name       : spRegisterPerson
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

drop procedure if exists spRegisterPerson;
delimiter $$
create procedure spRegisterPerson(in vFirstName varchar(32),
                                  in vLastName varchar(32),
                                  in vBirthDate date,
                                 out ObjectId smallint,
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PERSON';
    declare SprocName varchar(128) default 'spRegisterPerson';
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat(vFirstName, ': ', vLastName, ': ', vBirthDate);
 
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
 
    -- Attempt person registration ..
    set SprocComment = concat('Searching for ObjectId [', SignificantFields, ']');
    call spGetIdForPerson (vFirstName, vLastName, vBirthdate, ObjectId, ReturnCode);

    if (ObjectId is NULL) then
        set SprocComment = concat('ObjectId for [', SignificantFields, '] not found - Transaction required: INSERT');
        insert into 
                PERSON
                (
                 FIRST_NAME,
                 LAST_NAME,
                 BIRTH_DATE
                )
                values
                (
                 vFirstName,
                 vLastName,
                 vBirthDate
                );
        call spGetIdForPerson (vFirstName, vLastName, vBirthdate, ObjectId, ReturnCode);
    else
        set SprocComment = concat('ObjectId for [', SignificantFields, '] already exists');
    end if;
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
 
end$$
delimiter ;


/*
Sample Usage:

call spRegisterPerson ('Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from PERSON order by DATE_REGISTERED asc;
*/
