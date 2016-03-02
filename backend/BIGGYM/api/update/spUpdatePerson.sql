/*
Name       : spUpdatePerson
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForPerson
*/

use BIGGYM;

drop procedure if exists spUpdatePerson;
delimiter $$
create procedure spUpdatePerson(in vUpdatable_FirstName varchar(32),
                                in vUpdatable_LastName varchar(32),
                                in vUpdatable_BirthDate date,
                                in vUpdatable_Gender char(1),
                                in vUpdatable_BodyHeight float,
                             inout ObjectId mediumint unsigned,
                               out ReturnCode int,
                               out ErrorCode int,
                               out ErrorState int,
                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PERSON';
    declare SpName varchar(128) default 'spUpdatePerson';
    declare SignificantFields varchar(512) default concat('FIRST_NAME=', saynull(vUpdatable_FirstName), 
                                                          ',LAST_NAME=', saynull(vUpdatable_LastName), 
                                                          ',BIRTH_DATE=', saynull(vUpdatable_BirthDate),
                                                          ',GENDER=', saynull(vUpdatable_Gender),
                                                          ',HEIGHT=', saynull(vUpdatable_BodyHeight));
    declare ReferenceFields varchar(512) default concat('ID=', saynull(ObjectId));
    declare TransactionType varchar(16) default 'update';
    
    declare SpComment varchar(1024);
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
    if(strisgood(vUpdatable_FirstName) and strisgood(vUpdatable_LastName) and strisgood(vUpdatable_BirthDate)) then

        -- Only proceed with update when objectId not null ..
        if (ObjectId is NOT NULL) then
        
            -- Check if date uses valid format (YY-mm-dd) ..
            if (date(vUpdatable_BirthDate) is NOT NULL and (vUpdatable_BirthDate != '0000-00-00')) then
            
                -- Attempt update ..
                call spGetIdForPerson (vUpdatable_FirstName, vUpdatable_LastName, vUpdatable_BirthDate, localObjectId, ReturnCode);
                
                if (ObjectId = localObjectId) then
                    -- No update of significant fields required ..
                    set tStatus = 2;
        
                elseif (localObjectId is NULL) then
                    
                    -- Update significant fields as no duplicate already present ..
                    update PERSON
                       set
                           C_LASTMOD = current_timestamp(3),
                           FIRST_NAME = vUpdatable_FirstName,
                           LAST_NAME = vUpdatable_LastName,
                           BIRTH_DATE = vUpdatable_BirthDate
                     where
                           ID = ObjectId;
                
                    -- Verify ..
                    call spGetIdForPerson (vUpdatable_FirstName, vUpdatable_LastName, vUpdatable_BirthDate, localObjectId, ReturnCode);
                    if (ObjectId = localObjectId) then
                        -- success ..
                        set tStatus = 0;
                    else
                        -- transaction attempt made no change or caused duplicate ..
                        set tStatus = -2;
                    end if;
                else
                    -- transaction attempt ignored as duplicate exists ..
                    set tStatus = -3;
                end if;
            else
                -- invalid date format used ..
                set tStatus = -6;
            end if;
         else
            -- unexpected NULL value for Object and/or reference Id ..
            set tStatus = -7;
        end if;
    else
        -- illegal or null characters found ..
        set tStatus = -1;
    end if;
    
    -- Ensure non-significant fields are always updated in non problematic (tStatus >= 0) scenarios ..
    if (tStatus >= 0) then
        update PERSON
           set
               C_LASTMOD = current_timestamp(3),
               gender = ifNull(vUpdatable_Gender, '-'),
               body_height = ifNull(vUpdatable_BodyHeight, 0)
         where
               ID = ObjectId;
    end if;
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);   

end$$
delimiter ;