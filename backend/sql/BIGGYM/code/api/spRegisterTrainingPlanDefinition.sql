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
*/

use BIGGYM;

drop procedure if exists spRegisterTrainingPlanDefinition;
delimiter $$
create procedure spRegisterTrainingPlanDefinition(in vExerciseName varchar(128),
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
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
 	declare SpName varchar(128) default 'spRegisterTrainingPlanDefinition';
    declare SignificantFields varchar(256) default concat('PLANid, EXERCISEid');
    declare ReferenceFields varchar(256) default concat('EXERCISEid(', 'NAME=', vExerciseName, ',BODY_PART=', vBodyPartName, '>) and ' ,
														'PLANId(', 'NAME=', vTrainingPlanName, ') and ' ,
														'PROFILEId(', 'NAME=', vProfileName, ') and ' ,
														'PERSONid(', 'FIRST_NAME=', vFirstName, ',LAST_NAME=', vLastName, ',BIRTH_DATE=', vBirthDate, ')');
    declare TransactionType varchar(16) default 'insert'; 
    
    declare SpComment varchar(512);
    
    declare vPlanId mediumint unsigned default NULL;
    declare vExerciseId mediumint unsigned default NULL;
   
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
	call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    call spSimpleLog (ObjectName, SpName, concat('--[START] parameters: ', SpComment), ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

	-- Attempt create: Profile ..

    -- Attempt pre-emptive exercise-bodypart registration ..
    call spCreateExercise (vExerciseName, vBodyPartName, vExerciseId, ReturnCode, ErrorCode,ErrorState, ErrorMsg);

    -- Attempt pre-emptive profile registration cascade ..
    call spRegisterTrainingPlan (vTrainingPlanName, vProfileName, vFirstName, vLastName, vBirthDate, vPlanId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
 
    -- Attempt TrainingPlanDefinition registration ..
    if (vExerciseId is NOT NULL and vPlanId is NOT NULL) then
		call spCreateTrainingPlanDefinition (vExerciseId, vPlanId, ObjectId, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    end if;

    -- Log ..
	call spSimpleLog (ObjectName, SpName, concat('----[END] return code: ', ReturnCode), ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

call spRegisterTrainingPlanDefinition ('Curls','Arms', 'Get Bigger Workout', 'Faceman', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;

call spRegisterTrainingPlanDefinition ('Curls','Arms', 'Get Bigger Workout', 'Mr.T', 'Lawrence', 'Tureaud', '1952-05-21', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;

call spRegisterTrainingPlanDefinition ('Triceps Press','Arms', 'Get Bigger Workout', 'Mr.T', 'Lawrence', 'Tureaud', '1952-05-21', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;

select * from TRAINING_PLAN_DEFINITION order by DATE_REGISTERED asc;
*/
