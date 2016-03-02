/*
Name       : spRegisterTrainingPlan
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spSimpleLog
                - spRegisterProfile
                - spCreateTrainingPlan
                - spUpdateTrainingPlan
*/

use BIGGYM;

drop procedure if exists spRegisterTrainingPlan;
delimiter $$
create procedure spRegisterTrainingPlan(in vNewOrUpdatable_TrainingPlanName varchar(128),
                                        in vNewOrUpdatable_Objective varchar(32),
                                        in vNewOrUpdatable_Private char(1),
                                        in vProfile_Name varchar(32),
                                        in vPerson_FirstName varchar(32),
                                        in vPerson_LastName varchar(32),
                                        in vPerson_BirthDate date,
                                        in vPerson_Gender char(1),
                                        in vPerson_BodyHeight double,
                                     inout ObjectId mediumint unsigned,
                                       out ReturnCode int,
                                       out ErrorCode int,
                                       out ErrorState int,
                                       out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterTrainingPlan';
    declare SignificantFields varchar(512) default  concat('NAME=', saynull(vNewOrUpdatable_TrainingPlanName));
    declare ReferenceFields varchar(512) default concat('ID=', saynull(ObjectId),
                                                        ',PROFILEId(', 
                                                                    'NAME=', saynull(vProfile_Name),
                                                                    ',OBJECTIVE=', saynull(vNewOrUpdatable_Objective),
                                                                    ',PRIVATE=', saynull(vNewOrUpdatable_Private),
                                                                 ') and ' ,
                                                        'PERSONid(', 
                                                                    'FIRST_NAME=', saynull(vPerson_FirstName), 
                                                                    ',LAST_NAME=', saynull(vPerson_LastName), 
                                                                    ',BIRTH_DATE=', saynull(vPerson_BirthDate),
                                                                    ',GENDER=', saynull(vPerson_Gender),
                                                                    ',HEIGHT=', saynull(vPerson_BodyHeight),
                                                                ')');
    declare TransactionType varchar(16) default 'insert-update';   
    
    declare SpComment varchar(1024);
    declare tStatus varchar(64) default 0;
    
    declare oProfileId mediumint unsigned default NULL;    
    
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

    -- Get ProfileId ..
    call spRegisterProfile (vProfile_Name, vPerson_FirstName, vPerson_LastName, vPerson_BirthDate, vPerson_Gender, vPerson_BodyHeight, oProfileId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
     
    -- Register ..
    if (oProfileId is NOT NULL) then
            
        if (ObjectId is NULL) then
            -- create .. 
            call spCreateTrainingPlan (vNewOrUpdatable_TrainingPlanName, vNewOrUpdatable_Objective, vNewOrUpdatable_Private, oProfileId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        else
            -- update ..
            call spUpdateTrainingPlan (vNewOrUpdatable_TrainingPlanName, vNewOrUpdatable_Objective, vNewOrUpdatable_Private, oProfileId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        end if;

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
