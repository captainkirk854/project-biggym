/*
Name       : spRegisterPerson
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
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
 
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------
    declare CONTINUE handler for SQLEXCEPTION
        begin
          set @objectName = 'PERSON';
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

    -- Get ID ..
    set ObjectId = NULL;
    
    select 
        ID
      into
        ObjectId
      from 
        PERSON 
     where 
        FIRST_NAME = vFirstName 
       and 
        LAST_NAME = vLastName 
       and 
        BIRTH_DATE = vBirthdate 
   limit 1;
      
    -- If ID found, reset ReturnCode to 0 ..
    if (ObjectId is NOT NULL and ReturnCode != 0) then
        set ReturnCode = 0;
    end if;
 
end$$
delimiter ;


/*
Sample Usage:
call spRegisterPerson ('Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;
select * from PERSON order by DATE_REGISTERED asc;
*/
