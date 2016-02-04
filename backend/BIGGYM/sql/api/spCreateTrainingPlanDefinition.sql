/*
Name       : spCreateTrainingPlanDefinition
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
                - spActionOnEnd
                - spGetIdForTrainingPlanDefinition
*/

use BIGGYM;

drop procedure if exists spCreateTrainingPlanDefinition;
delimiter $$
create procedure spCreateTrainingPlanDefinition(in vExerciseId mediumint unsigned,
                                                in vPlanId mediumint unsigned,
                                               out ObjectId mediumint unsigned,
                                               out ReturnCode int,
                                               out ErrorCode int,
                                               out ErrorState int,
                                               out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'TRAINING_PLAN_DEFINITION';
    declare SpName varchar(128) default 'spCreateTrainingPlanDefinition';
    declare SignificantFields varchar(256) default concat('na');
    declare ReferenceFields varchar(256) default concat('PLANid=', vPlanId, ',EXERCISEid=',vExerciseId);
    declare TransactionType varchar(16) default 'insert';

    declare SpComment varchar(512);
    declare tStatus varchar(64) default '-';
    
    declare vNew_ExerciseWeek tinyint unsigned default 1;
    declare vNew_ExerciseDay tinyint unsigned default NULL;
    declare vNew_ExerciseOrdinality tinyint unsigned default NULL; 
   
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

    -- Attempt create ..
    call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseId, vNew_ExerciseWeek, vNew_ExerciseDay, vNew_ExerciseOrdinality, ObjectId, ReturnCode);
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
        -- success ..
        set tStatus = 0;
        call spGetIdForTrainingPlanDefinition (vPlanId, vExerciseId, vNew_ExerciseWeek, vNew_ExerciseDay, vNew_ExerciseOrdinality, ObjectId, ReturnCode);
    else
        -- already exists ..
        set tStatus = 1;
    end if;
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

set @planId=5;
set @ExerciseId=4;
call spCreateTrainingPlanDefinition (@ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

set @planId=NULL;
set @ExerciseId=4;
call spCreateTrainingPlanDefinition (@ExerciseId, @planId, @planDefinitionId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @planDefinitionId, @returnCode;

*/
