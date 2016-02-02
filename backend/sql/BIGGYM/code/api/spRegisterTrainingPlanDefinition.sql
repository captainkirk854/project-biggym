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
                - spCreateExercise 
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
                                                 out ObjectId mediumint unsigned,
                                                 out ReturnCode int,
                                                 out ErrorCode int,
                                                 out ErrorState int,
                                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    declare SprocName varchar(128) default 'spRegisterTrainingPlanDefinition';
    declare vPlanId mediumint unsigned default NULL;
    declare vExerciseWeek tinyint unsigned default NULL;
    declare vExerciseDay tinyint unsigned default NULL;
    declare vExerciseOrdinality tinyint unsigned default NULL;
    declare vExerciseId mediumint unsigned default NULL;   
    
    declare SignificantFields varchar(256) default concat(' PLANid, EXERCISEid ');
    declare ReferenceObjects varchar(256) default concat('EXERCISEid(', 'NAME = <', vExerciseName, '>, ' , 'BODY_PART = <', vBodyPartName, '>) and ' ,'PLANId(', 'NAME = <', vTrainingPlanName, '>) and ' , 'PROFILEId(', 'NAME = <', vProfileName, '>) and ' ,'PERSONid(', 'FIRST_NAME = <', vFirstName, '> ', 'LAST_NAME = <', vLastName, '> ', 'BIRTH_DATE = <', vBirthDate, '>)');
    declare SprocComment varchar(512) default concat('insert into object field list [', SignificantFields, '] ', 'using reference(s) [', ReferenceObjects, ']');
    
    declare tStatus varchar(64) default '-';   

    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare EXIT handler for SQLEXCEPTION
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
    call spCreateExercise (vExerciseName, 
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
        call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseWeek, vExerciseDay, vExerciseOrdinality, vExerciseId, ObjectId, ReturnCode); 
        if (ObjectId is NULL) then    
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
                set tStatus = 'SUCCESS';
                call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseWeek, vExerciseDay, vExerciseOrdinality, vExerciseId, ObjectId, ReturnCode);
        else
                set tStatus = 'FIELD VALUE(S) ALREADY PRESENT';
        end if;
    else
        set tStatus = 'CANNOT FIND REFERENCE OBJECT(S)';
    end if;

    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(ObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

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
