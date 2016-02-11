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
*/

use BIGGYM;

drop procedure if exists spRegisterTrainingPlan;
delimiter $$
create procedure spRegisterTrainingPlan(in vNew_TrainingPlanName varchar(128),
                                        in vProfileName varchar(32),
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
    declare SpName varchar(128) default 'spRegisterTrainingPlan';
    declare SignificantFields varchar(256) default concat('NAME=', vNew_TrainingPlanName);
    declare ReferenceFields varchar(256) default concat('PROFILEId(', 'NAME=', vProfileName, ') and ' ,
                                                        'PERSONid(', 'FIRST_NAME=', vFirstName, ',LAST_NAME=', vLastName, ',BIRTH_DATE=', vBirthDate, ')');
    declare TransactionType varchar(16) default 'insert';   
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
    
    declare vProfileId mediumint unsigned default NULL;    
    
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

    -- Attempt create: Profile ..
    call spRegisterProfile (vProfileName, vFirstName, vLastName, vBirthDate, vProfileId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
     
    -- Attempt create: Training Plan ..
    if (vProfileId is NOT NULL) then
        call spCreateTrainingPlan (vNew_TrainingPlanName, vProfileId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
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
