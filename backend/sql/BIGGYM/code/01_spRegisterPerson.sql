/*
Name       : spRegisterPerson
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spGetObjectId
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
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PERSON';
 
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
 
    -- Attempt person registration ..
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

    -- Get its ID ..
    set @getIdWhereClause = concat('FIRST_NAME = ''', vFirstName, ''' and LAST_NAME = ''', vLastName,  ''' and BIRTH_DATE = ''', vBirthdate, '''');
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
 
end$$
delimiter ;


/*
Sample Usage:

call spRegisterPerson ('Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;
select * from PERSON order by DATE_REGISTERED asc;
*/
