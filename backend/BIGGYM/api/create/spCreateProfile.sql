/*
Name       : spCreateProfile
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

drop procedure if exists spCreateProfile;
delimiter $$
create procedure spCreateProfile(in vNew_ProfileName varchar(32),
                                 in vPersonId mediumint unsigned,
                                out ObjectId mediumint unsigned,
                                out ReturnCode int,
                                out ErrorCode int,
                                out ErrorState int,
                                out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare SpName varchar(128) default 'spCreateProfile';
    declare SignificantFields varchar(256) default concat('NAME=', saynull(vNew_ProfileName));
    declare ReferenceFields varchar(256) default concat('PERSONid=', saynull(vPersonId));
    declare TransactionType varchar(16) default 'insert';

    declare SpComment varchar(512);
    declare tStatus varchar(64) default '-';
 
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
    if(strisgood(vNew_ProfileName) and vPersonId is NOT NULL) then
    
        -- Attempt create ..
        call spGetIdForProfile (vNew_ProfileName, vPersonId, ObjectId, ReturnCode);
        if (ObjectId is NULL) then
            insert into 
                    PROFILE
                    (
                     NAME,
                     PERSONid
                    )
                    values
                    (
                     vNew_ProfileName,
                     vPersonId
                    );
            -- success ..
            set tStatus = 0;
            call spGetIdForProfile (vNew_ProfileName, vPersonId, ObjectId, ReturnCode);
        else
            -- already exists ..
            set tStatus = 1;
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
