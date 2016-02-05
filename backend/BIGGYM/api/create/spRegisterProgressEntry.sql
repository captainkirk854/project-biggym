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
create procedure spRegisterProgressEntry(in vNew_SetOrdinality tinyint unsigned,
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
    declare SignificantFields varchar(256) default concat('DEFINITIONid');
    declare ReferenceFields varchar(256) default concat('EXERCISEid(', 'NAME=', vExerciseName, ',BODY_PART=', vBodyPartName, '>) and ' ,
                                                        'PLANId(', 'NAME=', vTrainingPlanName, ') and ' ,
                                                        'PROFILEId(', 'NAME=', vProfileName, ') and ' ,
                                                        'PERSONid(', 'FIRST_NAME=', vFirstName, ',LAST_NAME=', vLastName, ',BIRTH_DATE=', vBirthDate, ')');
    declare TransactionType varchar(16) default 'insert'; 
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
    
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

    -- Get TrainingPlanDefinition Id ..
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
                                                  vPlanDefinitionId, 
                                                  ReturnCode);

    if (vPlanDefinitionId is NOT NULL) then
        call spCreateProgressEntry (vNew_SetOrdinality, vNew_SetReps, vNew_SetWeight, vNew_DatePhysical, vPlanDefinitionId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        if(ErrorCode != 0) then
            -- unexpected database transaction problem encountered
            set tStatus = -5;
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


/*
Sample Usage:
set @SetOrdinality =3;
set @SetReps = 10;
set @SetWeight = 65.5;
set @DatePhysical = '1974-03-25';
set @ExerciseWeek = 2;
set @ExerciseDay = 1;
set @ExerciseOrdinality = 2;
set @ExerciseName = 'Bicep Barbell Curls';
set @BodyPartName = 'Arms';
set @TrainingPlanName = 'Ultimate Predator-beating training plan';
set @ProfileName = 'Dutch Schaefer';
set @FirstName = 'Arnold';
set @LastName = 'Schwarzenegger';
set @BirthDate = '1947-07-30';

call spRegisterProgressEntry (@SetOrdinality,
                              @SetReps,
                              @SetWeight,
                              @DatePhysical,
                              @ExerciseWeek,
                              @ExerciseDay,
                              @ExerciseOrdinality,
                              @ExerciseName,
                              @BodyPartName,
                              @TrainingPlanName,
                              @ProfileName,
                              @FirstName,
                              @LastName,
                              @BirthDate,
                              @id, @returnCode, @errorCode, @stateCode, @errorMsg);
                         
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
*/
