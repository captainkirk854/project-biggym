/*
Name       : spUpdateProfile
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
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
    declare SprocName varchar(128) default 'spUpdateProfile';
    
    declare SignificantFields varchar(256) default concat('NAME = <', vUpdatable_ProfileName, '>');
    declare WhereCondition varchar(256) default concat('where ID = ', ifNull(ObjectId, 'NULL'), ' and PERSONid = ', vPersonId);
    declare SprocComment varchar(512) default concat('update object field list [', SignificantFields, '] ', WhereCondition);   
    
    declare localObjectId mediumint unsigned;
    declare tStatus varchar(64) default '-';
 
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
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
    -- Error Handling --
    -- -------------------------------------------------------------------------

    -- Attempt profile update ..
    call spGetIdForProfile (vUpdatable_ProfileName, vPersonId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - NO CHANGE FROM CURRENT';
        
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
