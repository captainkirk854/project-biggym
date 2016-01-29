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
                - spGetObjectId
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

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare vPersonId smallint default NULL;
 
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
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
     
    -- Get its ID ..
    set @getIdWhereClause = concat('NAME = ''', vProfileName,  ''' and PERSONid = ', vPersonId);
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode); 

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
