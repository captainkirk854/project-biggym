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
                                  out ErrorState int,
                                  out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare SprocName varchar(128) default 'spRegisterProfile';
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat(vFirstName, ': ', vLastName, ': ', vBirthDate, ': ', vProfileName);
    declare vPersonId smallint default NULL;
 
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
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
    -- Error Handling --
    -- -------------------------------------------------------------------------

    -- Attempt pre-emptive person registration cascade ..
    call spRegisterPerson (vFirstName, 
                           vLastName, 
                           vBirthDate, 
                           vPersonId, 
                           ReturnCode, 
                           ErrorCode,
                           ErrorState,
                           ErrorMsg);
   
    -- Attempt Profile registration ..
    if (vPersonId is NOT NULL) then
    
        set SprocComment = concat('Searching for ObjectId [', SignificantFields, ']');
        set @getIdWhereClause = concat('NAME = ''', vProfileName,  ''' and PERSONid = ', vPersonId);
        call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
        
        if (ObjectId is NULL) then
            set SprocComment = concat('ObjectId for [', SignificantFields, '] not found - Transaction required: INSERT');
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
            call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
        else
            set SprocComment = concat('ObjectId for [', SignificantFields, '] already exists');
        end if;
        
    end if;
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

call spRegisterProfile ('Faceman', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
call spRegisterProfile ('StarBuck', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
call spRegisterProfile ('Starbuck', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from PROFILE order by DATE_REGISTERED asc;
*/
