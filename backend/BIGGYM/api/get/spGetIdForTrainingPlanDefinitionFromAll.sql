/*
Name       : spGetIdForTrainingPlanDefinitionFromAll
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

drop procedure if exists spGetIdForTrainingPlanDefinitionFromAll;
delimiter $$
create procedure spGetIdForTrainingPlanDefinitionFromAll(in vExerciseWeek tinyint unsigned,
                                                         in vExerciseDay tinyint unsigned,
                                                         in vExerciseOrdinality tinyint unsigned,
                                                         in vExerciseName varchar(128),
                                                         in vBodyPartName varchar(128),   
                                                         in vTrainingPlanName varchar(128),
                                                         in vProfileName varchar(32),
                                                         in vFirstName varchar(32),
                                                         in vLastName varchar(32),
                                                         in vBirthDate date,
                                                        out IdNullCode int,
                                                        out ObjectId mediumint unsigned,
                                                        out ReturnCode int)
begin

    -- Declare ..    
    declare vExerciseId mediumint unsigned;
    declare vPersonId mediumint unsigned default NULL;
    declare vProfileId mediumint unsigned default NULL;
    declare vPlanId mediumint unsigned default NULL;
       
    -- Prepare ..
    set IdNullCode = 0;
    set ReturnCode = 0;

    -- Get ..
    call spGetIdForExercise (vExerciseName, vBodyPartName, vExerciseId, ReturnCode);
    if (vExerciseId is NOT NULL) then
        call spGetIdForPerson (vFirstName, vLastName, vBirthDate, vPersonId, ReturnCode);
        if (vPersonId is NOT NULL) then
            call spGetIdForProfile (vProfileName, vPersonId, vProfileId, ReturnCode);
            if (vProfileId is NOT NULL) then
                call spGetIdForTrainingPlan (vTrainingPlanName, vProfileId, vPlanId, ReturnCode);
                if (vPlanId is NOT NULL) then
                    call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseId, vExerciseWeek, vExerciseDay, vExerciseOrdinality, ObjectId, ReturnCode);
                    if(ObjectId is NULL) then
                        set IdNullCode = -14; -- ObjectId is NULL
                    end if;
                else
                    set IdNullCode = -13; -- vPlanId is NULL
                end if;
            else
                set IdNullCode = -12; -- vProfileId is NULL
            end if;
        else
            set IdNullCode = -11; -- vPersonId is NULL
        end if;
    else
        set IdNullCode = -10; -- vExerciseId is NULL
    end if;
    
end$$
delimiter ;


/*
Sample Usage:

call spGetIdForTrainingPlanDefinitionFromAll (2, 1, 2, 'Bicep Barbell Curls','Arms', 'Ultimate Predator-beating training plan', 'Dutch Schaefer', 'Arnold', 'Schwarzenegger', '1947-07-30', @IdNullCode, @id, @returnCode);
select @id, @IdNullCode;

call spGetIdForTrainingPlanDefinitionFromAll (2, 1, 2, 'Bicep Barbell Curls','Arms', 'Ultimate Predator-beating training plan', 'XDutch Schaefer', 'Arnold', 'Schwarzenegger', '1947-07-30', @IdNullCode, @id, @returnCode);
select @id, @IdNullCode;
*/
