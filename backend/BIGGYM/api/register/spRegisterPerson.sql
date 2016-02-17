/*
Name       : spRegisterPerson
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spSimpleLog
                - spCreatePerson
                - spUpdatePerson
*/

use BIGGYM;

drop procedure if exists spRegisterPerson;
delimiter $$
create procedure spRegisterPerson(in vNewOrUpdatableFirstName varchar(32),
                                  in vNewOrUpdatableLastName varchar(32),
                                  in vNewOrUpdatableBirthDate date,      
                               inout ObjectId mediumint unsigned,
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterPerson';
    declare SignificantFields varchar(256) default concat('FIRST_NAME=', saynull(vNewOrUpdatableFirstName), 
                                                        ',LAST_NAME =', saynull(vNewOrUpdatableLastName), 
                                                        ',BIRTH_DATE =', saynull(vNewOrUpdatableBirthDate));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId));
    declare TransactionType varchar(16) default 'insert-update';

    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
    
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

    -- Register ..
    if (ObjectId is NULL) then
        -- create ..
        call spCreatePerson (vNewOrUpdatableFirstName, vNewOrUpdatableLastName, vNewOrUpdatableBirthDate, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    else
        -- update ..
        call spUpdatePerson (vNewOrUpdatableFirstName, vNewOrUpdatableLastName, vNewOrUpdatableBirthDate, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    end if;
    
    if(ErrorCode != 0) then
        -- unexpected database transaction problem encountered
        set tStatus = -5;
    else
        set tStatus = ReturnCode;
    end if;


    -- Log ..
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, '----[END]', ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;
