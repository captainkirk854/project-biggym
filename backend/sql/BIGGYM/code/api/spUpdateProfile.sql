/*
Name       : spUpdateProfile
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForProfile
*/

use BIGGYM;

drop procedure if exists spUpdateProfile;
delimiter $$
create procedure spUpdateProfile(in vUpdatable_ProfileName varchar(32),
                                 in vPersonId mediumint unsigned,
                                 in ObjectId mediumint unsigned,
                                out ReturnCode int,
                                out ErrorCode int,
                                out ErrorState int,
                                out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare SpName varchar(128) default 'spUpdateProfile';
    declare SignificantFields varchar(256) default concat('NAME=', vUpdatable_ProfileName);
    declare ReferenceFields varchar(256) default concat('ID=', ifNull(ObjectId, 'NULL'), ',PERSONid=', vPersonId);
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
    call spGetIdForProfile (vUpdatable_ProfileName, vPersonId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        -- no update required ..
        set tStatus = 2;
        
    elseif (ObjectId is NOT NULL) then
    
        -- Update ..
        update PROFILE
           set 
               DATE_REGISTERED = current_timestamp(3),
               NAME = vUpdatable_ProfileName
         where
               ID = ObjectId
           and
               PERSONid = vPersonId;
    
        -- Verify ..
        call spGetIdForProfile (vUpdatable_ProfileName, vPersonId, localObjectId, ReturnCode);
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
set @profileId=11;
call spUpdateProfile ('Faceman', @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg;


set @personId=10;
set @profileId=11;
call spUpdateProfile ('cara di hombre', @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @personId=10;
set @profileId=99;
call spUpdateProfile ('cara di hombre', @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg;
*/
