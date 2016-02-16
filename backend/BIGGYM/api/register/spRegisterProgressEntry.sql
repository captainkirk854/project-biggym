/*
Name       : spRegisterProgressEntry
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
*/

use BIGGYM;

drop procedure if exists spRegisterProgressEntry;
delimiter $$
create procedure spRegisterProgressEntry(in opMode varchar(64),                  -- REFERENCES_EXISTENCE_CREATE|REFERENCES_EXISTENCE_ASSUME
                                         in vNew_SetOrdinality tinyint unsigned,
                                         in vNew_SetReps tinyint unsigned,
                                         in vNew_SetWeight float,
                                         in vNew_DatePhysical datetime,
                                         in vExerciseWeek tinyint unsigned,
                                         in vExerciseDay tinyint unsigned,
                                         in vExerciseOrdinality tinyint unsigned,
                                         in vExerciseName varchar(128),
                                         in vBodyPartName varchar(128),   
                                         in vTrainingPlanName varchar(128),
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
    declare SpName varchar(128) default 'spRegisterProgressEntry';
    declare SignificantFields varchar(256) default concat('SET_ORDINALITY=', saynull(vNew_SetOrdinality), 
                                                          ',SET_REPS=', saynull(vNew_SetReps),
                                                          ',SET_WEIGHT=', saynull(vNew_SetWeight),
                                                          ',DATE_PHYSICAL=', saynull(vNew_DatePhysical));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId),
                                                        ',DEFINITIONid(', 
                                                                      'EXERCISE_WEEK=', saynull(vExerciseWeek), 
                                                                      ',EXERCISE_DAY=', saynull(vExerciseDay),
                                                                      ',EXERCISE_ORDINALITY=', saynull(vExerciseOrdinality),
                                                                    ') and ' ,
                                                        'EXERCISEid(', 
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
    declare TransactionType varchar(16) default 'insert'; 
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
    declare IdNullCode int default 0;
    
    declare vExerciseId mediumint unsigned;
    declare vPersonId mediumint unsigned default NULL;
    declare vProfileId mediumint unsigned default NULL;
    declare vPlanId mediumint unsigned default NULL;
    declare vPlanDefinitionId mediumint unsigned default NULL;
       
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    call spSimpleLog (ObjectName, SpName, concat('--[START] parameters: ', SpComment), ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

    -- Set operational mode if NULL or blank ..
    if(length(trim(opMode)) = 0 or (opMode is NULL)) then
      set opMode = "REFERENCES_EXISTENCE_CREATE";
    end if;

    -- Get TrainingPlanDefinition Id one way or another ..
    if (opMode = "REFERENCES_EXISTENCE_ASSUME") then
        call spGetIdForTrainingPlanDefinitionFromAll (vExerciseWeek,
                                                      vExerciseDay, 
                                                      vExerciseOrdinality, 
                                                      vExerciseName, 
                                                      vBodyPartName, 
                                                      vTrainingPlanName, 
                                                      vProfileName, 
                                                      vFirstName, 
                                                      vLastName, 
                                                      vBirthDate,
                                                      IdNullCode,
                                                      vPlanDefinitionId, 
                                                      ReturnCode);

    elseif (opMode = "REFERENCES_EXISTENCE_CREATE") then
        call spRegisterTrainingPlanDefinition  (vExerciseName, 
                                                vBodyPartName, 
                                                vTrainingPlanName, 
                                                vExerciseWeek, 
                                                vExerciseDay, 
                                                vExerciseOrdinality, 
                                                vProfileName, 
                                                vFirstName, 
                                                vLastName, 
                                                vBirthDate, 
                                                vPlanDefinitionId, 
                                                ReturnCode, 
                                                ErrorCode, 
                                                ErrorState, 
                                                ErrorMsg);
    else
        set vPlanDefinitionId = NULL;
    end if;

    if (vPlanDefinitionId is NOT NULL) then
        call spCreateProgressEntry (vNew_SetOrdinality, 
                                    vNew_SetReps, 
                                    vNew_SetWeight, 
                                    vNew_DatePhysical, 
                                    vPlanDefinitionId, 
                                    ObjectId, 
                                    ReturnCode, 
                                    ErrorCode, 
                                    ErrorState, 
                                    ErrorMsg);
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
