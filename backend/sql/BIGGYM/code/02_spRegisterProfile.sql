/*
Name       : spRegisterProfile
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spRegisterPerson
*/

use BIGGYM;

drop procedure if exists spRegisterProfile;
delimiter $$
create procedure spRegisterProfile(in vProfileName varchar(32),
                                   in vFirstName varchar(32),
                                   in vLastName varchar(32),
                                   in vBirthDate date,      
                                  out ObjectId smallint,
                                  out ReturnCode int,
                                  out ErrorCode int,
                                  out ErrorMsg varchar(512))
begin

    declare vPersonId smallint default NULL;
 
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
    declare CONTINUE handler for SQLEXCEPTION
        begin
          set @objectName = 'PROFILE';
          call spErrorHandler (ReturnCode, ErrorCode, ErrorMsg);
          call spDebugLogger (database(), @objectName, ReturnCode, ErrorCode, ErrorMsg);
        end;

    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Error Handling --
    -- -------------------------------------------------------------------------

    -- Attempt pre-emptive person registration ..
    call spRegisterPerson (vFirstName, 
                           vLastName, 
                           vBirthDate, 
                           vPersonId, 
                           returnCode, 
                           errorCode, 
                           errorMsg);
   
    -- Attempt Profile registration ..
    if (vPersonId is NOT NULL) then
    insert into 
            PROFILE
            (
             NAME,
             PERSONid
            )
            values
            (
             vProfileName,
             vPersonId
            );
    end if;
    
    -- Get ID ..
    set ObjectId = NULL;
    
    select 
        ID
      into
        ObjectId
      from 
        PROFILE 
     where 
        NAME = vProfileName 
       and 
        PERSONid = vPersonId 
   limit 1;   
    
    -- If ID found, reset ReturnCode to 0 ..
    if (ObjectId is NOT NULL and ReturnCode != 0) then
        set ReturnCode = 0;
    end if;    
 
end$$
delimiter ;


/*
Sample Usage:

call spRegisterProfile ('Faceman', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;
call spRegisterProfile ('StarBuck', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;
call spRegisterProfile ('Starbuck', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;
select * from PROFILE order by DATE_REGISTERED asc;
*/
