/*
Name       : spRegisterTrainingPlanDefinition
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - TRAINING_PLAN_DEFINITION
                - TRAINING_PLAN
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spSimpleLog
                - spCreateExercise
                - spRegisterTrainingPlan
                - spCreateTrainingPlanDefinition
                - spUpdateTrainingPlanDefinition
*/

use BIGGYM;

drop procedure if exists spRegisterTrainingPlanDefinition;
delimiter $$
create procedure spRegisterTrainingPlanDefinition(in vExerciseName varchar(128),
                                                  in vBodyPartName varchar(128),   
                                                  in vTrainingPlanName varchar(128),
                                                  in vNewOrUpdatable_ExerciseWeek tinyint unsigned,
                                                  in vNewOrUpdatable_ExerciseDay tinyint unsigned,
                                                  in vNewOrUpdatable_ExerciseOrdinality tinyint unsigned,               
                                                  in vProfileName varchar(32),
                                                  in vFirstName varchar(32),
                                                  in vLastName varchar(32),
                                                  in vBirthDate date,
                                               inout ObjectId mediumint unsigned,
                                                 out ReturnCode int,
                                                 out ErrorCode int,
                                                 out ErrorState int,
                                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterTrainingPlanDefinition';
    declare SignificantFields varchar(256) default concat('PLANid, EXERCISEid', 
                                                          ',EXERCISE_WEEK=', saynull(vNewOrUpdatable_ExerciseWeek), 
                                                          ',EXERCISE_DAY=', saynull(vNewOrUpdatable_ExerciseDay),
                                                          ',EXERCISE_ORDINALITY=', saynull(vNewOrUpdatable_ExerciseOrdinality));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId),
                                                        ',EXERCISEid(', 
                                                                     'NAME=', saynull(vExerciseName),
                                                                     ',BODY_PART=', saynull(vBodyPartName),
                                                                  ') and ' ,
                                                        'PLANId(', 
                                                                'NAME=', saynull(vTrainingPlanName),
                                                              ') and ' ,
                                                        'PROFILEId(', 
                                                                    'NAME=', saynull(vProfileName),
                                                                 ') and ' ,
                                                        'PERSONid(', 
                                                                    'FIRST_NAME=', saynull(vFirstName), 
                                                                    ',LAST_NAME =', saynull(vLastName), 
                                                                    ',BIRTH_DATE =', saynull(vBirthDate), 
                                                                ')');
    declare TransactionType varchar(16) default 'insert-update'; 
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
    
    declare vPlanId mediumint unsigned default NULL;
    declare vExerciseId mediumint unsigned default NULL;
   
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    call spSimpleLog (ObjectName, SpName, concat('--[START] parameters: ', SpComment), ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

    -- Attempt create: Exercise-Bodypart ..
    call spCreateExercise (vExerciseName, vBodyPartName, vExerciseId, ReturnCode, ErrorCode,ErrorState, ErrorMsg);

    -- Attempt create: Profile ..
    call spRegisterTrainingPlan (vTrainingPlanName, vProfileName, vFirstName, vLastName, vBirthDate, vPlanId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
 
    -- Attempt create: Training Plan Definition ..
    if (vPlanId is NOT NULL and vExerciseId is NOT NULL) then
    
        if (ObjectId is NULL) then
            -- create ..    
            call spCreateTrainingPlanDefinition (vPlanId, vExerciseId, vNewOrUpdatable_ExerciseWeek, vNewOrUpdatable_ExerciseDay, vNewOrUpdatable_ExerciseOrdinality, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        else
            -- update
            call spUpdateTrainingPlanDefinition (vPlanId, vExerciseId, vNewOrUpdatable_ExerciseWeek, vNewOrUpdatable_ExerciseDay, vNewOrUpdatable_ExerciseOrdinality, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
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