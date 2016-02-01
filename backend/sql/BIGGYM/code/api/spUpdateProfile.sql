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
create procedure spUpdateProfile(in vProfileName varchar(32),
                                 in vPersonId smallint,
                                 in ObjectId smallint,
                                out ReturnCode int,
                                out ErrorCode int,
                                out ErrorState int,
                                out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare SprocName varchar(128) default 'spUpdateProfile';
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat('PERSONid = <', vPersonId, '> : ', 
                                                          'NAME = <', vProfileName, '> : ',
                                                          'ID = <', ObjectId, '>');
    
    declare localObjectId smallint;
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
    call spGetIdForProfile (vProfileName, vPersonId, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - UPDATE RESULTS IN NO CHANGE';
        
    elseif (ObjectId is NOT NULL) then
        set SprocComment = concat('Update to [', SignificantFields, '] where ID = ', ObjectId, ' Transaction: UPDATE');
        
        -- Update ..
        update PROFILE
           set 
               DATE_REGISTERED = current_timestamp(3),
               NAME = vProfileName
         where
               ID = ObjectId;
    
        -- Verify ..
        call spGetIdForProfile (vProfileName, vPersonId, localObjectId, ReturnCode);
        if (ObjectId = localObjectId) then
          set tStatus = 'SUCCESS';
        else
          set tStatus = 'FAILURE';
        end if;
    else
        set tStatus = 'IGNORED';
    end if;
    
    -- Log ..
    set SprocComment = concat('Update OBJECT to [', SignificantFields, '] where ID = ', ifNull(ObjectId, 'NULL'), ':  ', tStatus);
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
