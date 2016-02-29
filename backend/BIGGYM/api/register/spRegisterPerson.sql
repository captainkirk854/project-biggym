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
create procedure spRegisterPerson(in vNewOrUpdatable_FirstName varchar(32),
                                  in vNewOrUpdatable_LastName varchar(32),
                                  in vNewOrUpdatable_BirthDate date,
                                  in vNewOrUpdatable_Gender char(1),
                                  in vNewOrUpdatable_BodyHeight float,
                               inout ObjectId mediumint unsigned,
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterPerson';
    declare SignificantFields varchar(512) default concat('FIRST_NAME=', saynull(vNewOrUpdatable_FirstName), 
                                                          ',LAST_NAME=', saynull(vNewOrUpdatable_LastName), 
                                                          ',BIRTH_DATE=', saynull(vNewOrUpdatable_BirthDate),
                                                          ',GENDER=', saynull(vNewOrUpdatable_Gender),
                                                          ',HEIGHT=', saynull(vNewOrUpdatable_BodyHeight));
    declare ReferenceFields varchar(512) default concat('ID=', saynull(ObjectId));
    declare TransactionType varchar(16) default 'insert-update';

    declare SpComment varchar(1024);
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
        call spCreatePerson (vNewOrUpdatable_FirstName, vNewOrUpdatable_LastName, vNewOrUpdatable_BirthDate, vNewOrUpdatable_Gender, vNewOrUpdatable_BodyHeight, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    else
        -- update ..
        call spUpdatePerson (vNewOrUpdatable_FirstName, vNewOrUpdatable_LastName, vNewOrUpdatable_BirthDate, vNewOrUpdatable_Gender, vNewOrUpdatable_BodyHeight, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
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
