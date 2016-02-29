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
create procedure spRegisterTrainingPlanDefinition(in vExercise_Name varchar(128),
                                                  in vExercise_BodyPartName varchar(128),   
                                                  in vTrainingPlan_Name varchar(128),
                                                  in vTrainingPlan_Objective varchar(32),
                                                  in vTrainingPlan_Private char(1),
                                                  in vNewOrUpdatable_ExerciseWeek tinyint unsigned,
                                                  in vNewOrUpdatable_ExerciseDay tinyint unsigned,
                                                  in vNewOrUpdatable_ExerciseOrdinality tinyint unsigned,               
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
    declare SpName varchar(128) default 'spRegisterTrainingPlanDefinition';
    declare SignificantFields varchar(512) default concat('PLANid, EXERCISEid', 
                                                          ',EXERCISE_WEEK=', saynull(vNewOrUpdatable_ExerciseWeek), 
                                                          ',EXERCISE_DAY=', saynull(vNewOrUpdatable_ExerciseDay),
                                                          ',EXERCISE_ORDINALITY=', saynull(vNewOrUpdatable_ExerciseOrdinality));
    declare ReferenceFields varchar(512) default concat('ID=', saynull(ObjectId),
                                                        ',EXERCISEid(', 
                                                                     'NAME=', saynull(vExercise_Name),
                                                                     ',BODY_PART=', saynull(vExercise_BodyPartName),
                                                                  ') and ' ,
                                                        'PLANId(', 
                                                                'NAME=', saynull(vTrainingPlan_Name),
                                                                ',OBJECTIVE=', saynull(vTrainingPlan_Objective),
                                                                ',PRIVATE=', saynull(vTrainingPlan_Private),
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
    
    declare SpComment varchar(1024);
    declare tStatus varchar(64) default 0;
    
    declare oPlanId mediumint unsigned default NULL;
    declare oExerciseId mediumint unsigned default NULL;
   
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    call spSimpleLog (ObjectName, SpName, concat('--[START] parameters: ', SpComment), ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

    -- Get ExerciseId ..
    call spCreateExercise (vExercise_Name, vExercise_BodyPartName, oExerciseId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

    -- Get PlanId ..
    call spRegisterTrainingPlan (vTrainingPlan_Name, vTrainingPlan_Objective, vTrainingPlan_Private, vProfile_Name, vPerson_FirstName, vPerson_LastName, vPerson_BirthDate, vPerson_Gender, vPerson_BodyHeight, oPlanId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
 
    -- Register ..
    if (oPlanId is NOT NULL and oExerciseId is NOT NULL) then
    
        if (ObjectId is NULL) then
            -- create ..    
            call spCreateTrainingPlanDefinition (oPlanId, oExerciseId, vNewOrUpdatable_ExerciseWeek, vNewOrUpdatable_ExerciseDay, vNewOrUpdatable_ExerciseOrdinality, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        else
            -- update
            call spUpdateTrainingPlanDefinition (oPlanId, oExerciseId, vNewOrUpdatable_ExerciseWeek, vNewOrUpdatable_ExerciseDay, vNewOrUpdatable_ExerciseOrdinality, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
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