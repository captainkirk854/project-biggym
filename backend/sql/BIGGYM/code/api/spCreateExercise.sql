/*
Name       : spCreateExercise
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spGetIdForExercise
*/

use BIGGYM;

drop procedure if exists spCreateExercise;
delimiter $$
create procedure spCreateExercise(in vNew_ExerciseName varchar(128),
                                  in vNew_BodyPartName varchar(128),
                                 out ObjectId mediumint unsigned,  
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';
    declare SprocName varchar(128) default 'spCreateExercise';
    
    declare SignificantFields varchar(256) default concat('NAME = <', vNew_ExerciseName, '> ', 'BODY PART = <', vNew_BodyPartName, '>');
    declare ReferenceObjects varchar(256) default concat(' NONE ');
    declare SprocComment varchar(512) default concat('insert into object field list [', SignificantFields, '] ', 'using reference(s) [', ReferenceObjects, ']');
    
    declare tStatus varchar(64) default '-';

    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
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
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------
    
    -- Clean character input ..
    set vNew_ExerciseName = strcln(vNew_ExerciseName);
    set vNew_BodyPartName = strcln(vNew_BodyPartName);
 
    -- Check for valid input ..
    if(length(vNew_ExerciseName)*length(vNew_BodyPartName) != 0) then
 
        -- Attempt exercise registration ..
        call spGetIdForExercise (vNew_ExerciseName, vNew_BodyPartName, ObjectId, ReturnCode);
        if (ObjectId is NULL) then
            insert into 
                    EXERCISE
                    (
                     NAME,
                     BODY_PART
                    )
                    values
                    (
                     vNew_ExerciseName,
                     vNew_BodyPartName
                    );
            set tStatus = 'SUCCESS';
            call spGetIdForExercise (vNew_ExerciseName, vNew_BodyPartName, ObjectId, ReturnCode);
        else
            set tStatus = 'FIELD VALUE(S) ALREADY PRESENT';
        end if;
    else
        set tStatus = 'ONLY ILLEGAL CHARACTERS IN ONE OR MORE FIELD VALUE(S)';
        set ReturnCode = -1;
    end if;

    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(ObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

call spCreateExercise ('Pullups', 'Back', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;


call spCreateExercise ('!!!!***', 'Back', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from EXERCISE order by DATE_REGISTERED asc;
*/
