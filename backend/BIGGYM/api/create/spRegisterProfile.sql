/*
Name       : spRegisterProfile
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spSimpleLog
                - spCreatePerson
                - spCreateProfile
*/

use BIGGYM;

drop procedure if exists spRegisterProfile;
delimiter $$
create procedure spRegisterProfile(in vNew_ProfileName varchar(32),
                                   in vFirstName varchar(32),
                                   in vLastName varchar(32),
                                   in vBirthDate date,      
                                  out ObjectId mediumint unsigned,
                                  out ReturnCode int,
                                  out ErrorCode int,
                                  out ErrorState int,
                                  out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterProfile';
    declare SignificantFields varchar(256) default concat('NAME=', saynull(vNew_ProfileName));
    declare ReferenceFields varchar(256) default concat('FIRST_NAME=', saynull(vFirstName), 
                                                        ',LAST_NAME =', saynull(vLastName), 
                                                        ',BIRTH_DATE =', saynull(vBirthDate));
    declare TransactionType varchar(16) default 'insert';

    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
    
    declare vPersonId mediumint unsigned default NULL;
    
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
    call spSimpleLog (ObjectName, SpName, concat('--[START] parameters: ', SpComment), ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

    -- Attempt create: Person ..
    call spCreatePerson (vFirstName, vLastName, vBirthDate, vPersonId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
  
    -- Attempt create: Profile ..
    if (vPersonId is NOT NULL) then
        call spCreateProfile (vNew_ProfileName, vPersonId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        if(ErrorCode != 0) then
            -- unexpected database transaction problem encountered
            set tStatus = -5;
        else
            set tStatus = ReturnCode;
        end if;
    else
        -- unexpected NULL value for one or more REFERENCEid(s)
        set tStatus = -4;
        set ReturnCode = tStatus;
    end if;

    -- Log ..
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, '----[END]', ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;
