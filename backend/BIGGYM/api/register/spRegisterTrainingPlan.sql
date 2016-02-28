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
                                        in vProfileName varchar(32),
                                        in vFirstName varchar(32),
                                        in vLastName varchar(32),
                                        in vBirthDate date,
                                        in vGender char(1),
                                        in vBodyHeight float,
                                     inout ObjectId mediumint unsigned,
                                       out ReturnCode int,
                                       out ErrorCode int,
                                       out ErrorState int,
                                       out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterTrainingPlan';
    declare SignificantFields varchar(256) default  concat('NAME=', saynull(vNewOrUpdatable_TrainingPlanName));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId),
                                                        ',PROFILEId(', 
                                                                    'NAME=', saynull(vProfileName),
                                                                 ') and ' ,
                                                        'PERSONid(', 
                                                                    'FIRST_NAME=', saynull(vFirstName), 
                                                                    ',LAST_NAME=', saynull(vLastName), 
                                                                    ',BIRTH_DATE=', saynull(vBirthDate),
                                                                    ',GENDER=', saynull(vGender),
                                                                    ',HEIGHT=', saynull(vBodyHeight),
                                                                ')');
    declare TransactionType varchar(16) default 'insert-update';   
    
    declare SpComment varchar(512);
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
    call spRegisterProfile (vProfileName, vFirstName, vLastName, vBirthDate, vGender, vBodyHeight, oProfileId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
     
    -- Register ..
    if (oProfileId is NOT NULL) then
            
        if (ObjectId is NULL) then
            -- create .. 
            call spCreateTrainingPlan (vNewOrUpdatable_TrainingPlanName, oProfileId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        else
            -- update ..
            call spUpdateTrainingPlan (vNewOrUpdatable_TrainingPlanName, oProfileId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
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
