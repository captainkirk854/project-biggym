/*
Name       : spUpdateTrainingPlan
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

drop procedure if exists spUpdateTrainingPlan;
delimiter $$
create procedure spUpdateTrainingPlan(in vUpdatable_TrainingPlanName varchar(128),
                                      in vUpdatable_Objective varchar(32),
                                      in vUpdatable_Private char(1),
                                      in vProfileId mediumint unsigned,
                                   inout ObjectId mediumint unsigned,
                                     out ReturnCode int,
                                     out ErrorCode int,
                                     out ErrorState int,
                                     out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN';
    declare SpName varchar(128) default 'spUpdateTrainingPlan';
    declare SignificantFields varchar(256) default concat('NAME=', saynull(vUpdatable_TrainingPlanName),
                                                          ',OBJECTIVE=', saynull(vUpdatable_Objective),
                                                          ',PRIVATE=', saynull(vUpdatable_Private));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId), 
                                                        ',PROFILEid=', saynull(vProfileId));
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
    if(strisgood(vUpdatable_TrainingPlanName)) then

        -- Only proceed for not null objectId and reference Id(s)..
        if (ObjectId is NOT NULL and vProfileId is NOT NULL) then

            -- Attempt update ..
            call spGetIdForTrainingPlan (vUpdatable_TrainingPlanName, vProfileId, localObjectId, ReturnCode);
            if (ObjectId = localObjectId) then
                -- no update required ..
                set tStatus = 2;
                
            elseif (localObjectId is NULL) then
            
                -- Can update as no duplicate exists ..
                update TRAINING_PLAN
                   set 
                       DATE_REGISTERED = current_timestamp(3),
                       NAME = vUpdatable_TrainingPlanName,
                       objective = vUpdatable_Objective,
                       private = vUpdatable_Private
                 where
                       ID = ObjectId
                   and
                       PROFILEid = vProfileId;
            
                -- Verify ..
                call spGetIdForTrainingPlan (vUpdatable_TrainingPlanName, vProfileId, localObjectId, ReturnCode);
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
