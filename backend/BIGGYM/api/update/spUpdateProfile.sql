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
                              inout ObjectId mediumint unsigned,
                                out ReturnCode int,
                                out ErrorCode int,
                                out ErrorState int,
                                out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare SpName varchar(128) default 'spUpdateProfile';
    declare SignificantFields varchar(256) default concat('NAME=', saynull(vUpdatable_ProfileName));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId), 
                                                        ',PERSONid=', saynull(vPersonId));
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
    
    
    -- Only "good" string input is allowed ..
    if(strisgood(vUpdatable_ProfileName)) then

        -- Only proceed for not null objectId and reference Id(s)..
        if (ObjectId is NOT NULL and vPersonId is NOT NULL) then
 
            -- Attempt update ..
            call spGetIdForProfile (vUpdatable_ProfileName, vPersonId, localObjectId, ReturnCode);
            if (ObjectId = localObjectId) then
                -- no update required ..
                set tStatus = 2;
                
            elseif (localObjectId is NULL) then
            
                -- Can update as no duplicate exists ..
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
                    -- transaction attempt made no change or caused duplicate ..
                    set tStatus = -2;
                    rollback;
                end if;
            else
                -- transaction attempt ignored as duplicate exists ..
                set tStatus = -3;
            end if;
         else
            -- unexpected NULL value for Object and/or reference Id ..
            set tStatus = -7;
        end if;       
    else
        -- illegal or null characters found ..
        set tStatus = -1;
    end if;
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

end$$
delimiter ;
