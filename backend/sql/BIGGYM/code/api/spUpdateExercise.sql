/*
Name       : spUpdateExercise
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

drop procedure if exists spUpdateExercise;
delimiter $$
create procedure spUpdateExercise(in vUpdatable_ExerciseName varchar(128),
                                  in vUpdatable_BodyPartName varchar(128),
                                  in ObjectId smallint,  
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';
    declare SprocName varchar(128) default 'spUpdateExercise';
    
    declare SignificantFields varchar(256) default concat('NAME = <', vUpdatable_ExerciseName, '> ', 'BODY PART = <', vUpdatable_BodyPartName, '>');
	declare WhereCondition varchar(256) default concat('WHERE ID = ', ifNull(ObjectId, 'NULL'));
    declare SprocComment varchar(512) default concat('UPDATE OBJECT FIELD LIST [', SignificantFields, '] ', WhereCondition);
    
    declare localObjectId smallint;
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

    -- Attempt exercise update ..
    call spGetIdForExercise (vUpdatable_ExerciseName, vUpdatable_BodyPartName, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - NO CHANGE FROM CURRENT';
        
    elseif (ObjectId is NOT NULL) then
	
        -- Update ..
        update EXERCISE
           set 
               DATE_REGISTERED = current_timestamp(3),
               NAME = vUpdatable_ExerciseName,
               BODY_PART = vUpdatable_BodyPartName
         where
               ID = ObjectId;
    
        -- Verify ..
        call spGetIdForExercise (vUpdatable_ExerciseName, vUpdatable_BodyPartName, localObjectId, ReturnCode);
        if (ObjectId = localObjectId) then
          set tStatus = 'SUCCESS';
        else
          set tStatus = 'FAILURE';
        end if;
    else
        set tStatus = 'IGNORED';
    end if;
    
    -- Log ..
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:
set @exerciseId=9;
call spUpdateExercise ('Pullups', 'Back', @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @exerciseId=10;
call spUpdateExercise ('Pullups', 'Back', @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @exerciseId = NULL;
call spUpdateExercise ('Pullups', 'Back', @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @exerciseId=9;
call spUpdateExercise ('Pullups-Speziale', 'Back', @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg);
select  @exerciseId, @returnCode, @errorCode, @stateCode, @errorMsg;
*/
