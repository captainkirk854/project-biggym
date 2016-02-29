/*
Name       : spCreateTrainingPlan
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForTrainingPlan
*/

use BIGGYM;

drop procedure if exists spCreateTrainingPlan;
delimiter $$
create procedure spCreateTrainingPlan(in vNew_TrainingPlanName varchar(128),
                                      in vNew_Objective varchar(32),
                                      in vNew_Private char(1),
                                      in vProfileId mediumint unsigned,
                                     out ObjectId mediumint unsigned,
                                     out ReturnCode int,
                                     out ErrorCode int,
                                     out ErrorState int,
                                     out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN';
    declare SpName varchar(128) default 'spCreateTrainingPlan';
    declare SignificantFields varchar(256) default concat('NAME=', saynull(vNew_TrainingPlanName),
                                                          ',OBJECTIVE=', saynull(vNew_Objective),
                                                          ',PRIVATE=', saynull(vNew_Private));
    declare ReferenceFields varchar(256) default concat('PROFILEid=', saynull(vProfileId));
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
    if(strisgood(vNew_TrainingPlanName) and vProfileId is NOT NULL) then

        -- Attempt create ..
        call spGetIdForTrainingPlan (vNew_TrainingPlanName, vProfileId, ObjectId, ReturnCode);
        if (ObjectId is NULL) then
            insert into 
                    TRAINING_PLAN
                    (
                     NAME,
                     objective,
                     private,
                     PROFILEid
                    )
                    values
                    (
                     vNew_TrainingPlanName,
                     ifNull(vNew_Objective, 'Other'),
                     ifNull(vNew_Private, 'N'),
                     vProfileId
                    );
            -- success ..
            set tStatus = 0;
            call spGetIdForTrainingPlan (vNew_TrainingPlanName, vProfileId, ObjectId, ReturnCode);
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
