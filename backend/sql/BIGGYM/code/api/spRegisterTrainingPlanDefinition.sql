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
                - spDebugLogger 
                - spErrorHandler
                - spRegisterTrainingPlan
                - spGetIdForTrainingPlanDefinition
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
                                                 out ObjectId smallint,
                                                 out ReturnCode int,
                                                 out ErrorCode int,
                                                 out ErrorState int,
                                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    declare SprocName varchar(128) default 'spRegisterTrainingPlanDefinition';
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat(vFirstName, ': ', vLastName, ': ', vBirthDate, ': ', vProfileName, ': ', vTrainingPlanName, ': ', vExerciseName, ': ', vBodyPartName);
    declare vExerciseId smallint default NULL;
    declare vPlanId smallint default NULL;
    
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare CONTINUE handler for SQLEXCEPTION
        begin
           set SprocComment = concat('SEVERITY 1 EXCEPTION: ', SprocComment);
          call spErrorHandler (ReturnCode, ErrorCode, ErrorState, ErrorMsg);
          call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        end;
 
    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Error Handling --
    -- -------------------------------------------------------------------------

    -- Attempt pre-emptive exercise-bodypart registration ..
    call spRegisterExercise (vExerciseName, 
                             vBodyPartName, 
                             vExerciseId, 
                             ReturnCode, 
                             ErrorCode,
                             ErrorState,
                             ErrorMsg);

    -- Attempt pre-emptive profile registration cascade ..
    call spRegisterTrainingPlan (vTrainingPlanName, 
                                 vProfileName, 
                                 vFirstName, 
                                 vLastName, 
                                 vBirthDate, 
                                 vPlanId, 
                                 ReturnCode, 
                                 ErrorCode,
                                 ErrorState,
                                 ErrorMsg);
 
    -- Attempt TrainingPlanDefinition registration ..
    if (vPlanId is NOT NULL and vExerciseId is NOT NULL) then
    
        set SprocComment = concat('Searching for ObjectId [', SignificantFields, ']');
        call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseId, ObjectId, ReturnCode);
    
        if (ObjectId is NULL) then
            set SprocComment = concat('ObjectId for [', SignificantFields, '] not found - Transaction required: INSERT');    
            insert into 
                    TRAINING_PLAN_DEFINITION
                    (
                     PLANId,
                     EXERCISEid
                    )
                    values
                    (
                     vPlanId,
                     vExerciseId
                    );
            call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseId, ObjectId, ReturnCode);
        else
            set SprocComment = concat('ObjectId for [', SignificantFields, '] already exists');
        end if;
        call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
                
    end if;

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
