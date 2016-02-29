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
create procedure spRegisterProgressEntry(in opMode varchar(64),                  -- REFERENCE_CREATE|REFERENCE_ASSUME
                                         in vNewOrUpdatable_SetOrdinality tinyint unsigned,
                                         in vNewOrUpdatable_SetReps tinyint unsigned,
                                         in vNewOrUpdatable_SetWeight float,
                                         in vNewOrUpdatable_SetDatestamp datetime,
                                         in vTrainingPlanDefinition_ExerciseWeek tinyint unsigned,
                                         in vTrainingPlanDefinition_ExerciseDay tinyint unsigned,
                                         in vTrainingPlanDefinition_ExerciseOrdinality tinyint unsigned,
                                         in vExercise_Name varchar(128),
                                         in vExercise_BodyPartName varchar(128),   
                                         in vTrainingPlan_Name varchar(128),
                                         in vTrainingPlan_Objective varchar(32),
                                         in vTrainingPlan_Private char(1),
                                         in vProfile_Name varchar(32),
                                         in vPerson_FirstName varchar(32),
                                         in vPerson_LastName varchar(32),
                                         in vPerson_BirthDate date,
                                         in vPerson_Gender char(1),
                                         in vPerson_BodyHeight float,
                                      inout ObjectId mediumint unsigned,
                                        out ReturnCode int,
                                        out ErrorCode int,
                                        out ErrorState int,
                                        out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterProgressEntry';
    declare SignificantFields varchar(256) default concat('SET_ORDINALITY=', saynull(vNewOrUpdatable_SetOrdinality), 
                                                          ',SET_REPS=', saynull(vNewOrUpdatable_SetReps),
                                                          ',SET_WEIGHT=', saynull(vNewOrUpdatable_SetWeight),
                                                          ',SET_DATE=', saynull(vNewOrUpdatable_SetDatestamp));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId),
                                                        ',DEFINITIONid(', 
                                                                      'EXERCISE_WEEK=', saynull(vTrainingPlanDefinition_ExerciseWeek), 
                                                                      ',EXERCISE_DAY=', saynull(vTrainingPlanDefinition_ExerciseDay),
                                                                      ',EXERCISE_ORDINALITY=', saynull(vTrainingPlanDefinition_ExerciseOrdinality),
                                                                    ') and ' ,
                                                        'EXERCISEid(', 
                                                                     'NAME=', saynull(vExercise_Name),
                                                                     ',BODY_PART=', saynull(vExercise_BodyPartName),
                                                                    ') and ' ,
                                                        'PLANId(', 
                                                                'NAME=', saynull(vTrainingPlan_Name),
                                                              ') and ' ,
                                                        'PROFILEId(', 
                                                                    'NAME=', saynull(vProfile_Name),
                                                                 ') and ' ,
                                                        'PERSONid(', 
                                                                    'FIRST_NAME=', saynull(vPerson_FirstName), 
                                                                    ',LAST_NAME=', saynull(vPerson_LastName), 
                                                                    ',BIRTH_DATE=', saynull(vPerson_BirthDate),
                                                                    ',GENDER=', saynull(vPerson_Gender),
                                                                    ',HEIGHT=', saynull(vPerson_BodyHeight),
                                                                ')');
    declare TransactionType varchar(16) default 'insert-update'; 
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
    declare IdNullCode int default 0;
    
    declare oExerciseId mediumint unsigned;
    declare oPersonId mediumint unsigned default NULL;
    declare oProfileId mediumint unsigned default NULL;
    declare oPlanId mediumint unsigned default NULL;
    declare oPlanDefinitionId mediumint unsigned default NULL;
       
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    call spSimpleLog (ObjectName, SpName, concat('--[START] parameters: ', SpComment), ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

    -- Set operational mode if NULL or blank ..
    if(length(trim(opMode)) = 0 or (opMode is NULL)) then
      set opMode = "REFERENCE_CREATE";
    end if;

    -- Get TrainingPlanDefinition Id  ..
    if (opMode = "REFERENCE_ASSUME") then
        call spGetIdForTrainingPlanDefinitionFromAll (vTrainingPlanDefinition_ExerciseWeek,
                                                      vTrainingPlanDefinition_ExerciseDay, 
                                                      vTrainingPlanDefinition_ExerciseOrdinality, 
                                                      vExercise_Name, 
                                                      vExercise_BodyPartName, 
                                                      vTrainingPlan_Name, 
                                                      vProfile_Name, 
                                                      vPerson_FirstName, 
                                                      vPerson_LastName, 
                                                      vPerson_BirthDate,
                                                      IdNullCode,
                                                      oPlanDefinitionId, 
                                                      ReturnCode);

    elseif (opMode = "REFERENCE_CREATE") then
        call spRegisterTrainingPlanDefinition  (vExercise_Name, 
                                                vExercise_BodyPartName, 
                                                vTrainingPlan_Name,
                                                vTrainingPlan_Objective,
                                                vTrainingPlan_Private,
                                                vTrainingPlanDefinition_ExerciseWeek, 
                                                vTrainingPlanDefinition_ExerciseDay, 
                                                vTrainingPlanDefinition_ExerciseOrdinality, 
                                                vProfile_Name,
                                                vPerson_FirstName, 
                                                vPerson_LastName, 
                                                vPerson_BirthDate,
                                                vPerson_Gender,
                                                vPerson_BodyHeight,
                                                oPlanDefinitionId, 
                                                ReturnCode, 
                                                ErrorCode, 
                                                ErrorState, 
                                                ErrorMsg);
    else
        set oPlanDefinitionId = NULL;
    end if;

    -- Register ..
    if (oPlanDefinitionId is NOT NULL) then
        if (ObjectId is NULL) then
            -- create ..
            call spCreateProgressEntry (vNewOrUpdatable_SetOrdinality, 
                                        vNewOrUpdatable_SetReps, 
                                        vNewOrUpdatable_SetWeight, 
                                        vNewOrUpdatable_SetDatestamp, 
                                        oPlanDefinitionId, 
                                        ObjectId, 
                                        ReturnCode, 
                                        ErrorCode, 
                                        ErrorState, 
                                        ErrorMsg);
        else
            -- update ..
            call spUpdateProgressEntry (vNewOrUpdatable_SetOrdinality, 
                                        vNewOrUpdatable_SetReps, 
                                        vNewOrUpdatable_SetWeight, 
                                        vNewOrUpdatable_SetDatestamp, 
                                        oPlanDefinitionId, 
                                        ObjectId, 
                                        ReturnCode, 
                                        ErrorCode, 
                                        ErrorState, 
                                        ErrorMsg);
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
