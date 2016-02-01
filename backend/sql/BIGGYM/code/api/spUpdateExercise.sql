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
create procedure spUpdateExercise(in vExerciseName varchar(128),
                                  in vBodyPartName varchar(128),
                                  in ObjectId smallint,  
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';
    declare SprocName varchar(128) default 'spUpdateExercise';
    declare SprocComment varchar(512) default '';
    declare SignificantFields varchar(256) default concat('NAME = <', vExerciseName, '> : ',
                                                          'BODY PART = <', vBodyPartName, '> : ',
                                                          'ID = <', ObjectId, '>');
    
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
    call spGetIdForExercise (vExerciseName, vBodyPartName, localObjectId, ReturnCode);
    if (ObjectId = localObjectId) then
        set tStatus = 'IGNORED - UPDATE RESULTS IN NO CHANGE';
        
    elseif (ObjectId is NOT NULL) then
        set SprocComment = concat('Update to [', SignificantFields, '] where ID = ', ObjectId, ' Transaction: UPDATE');
        
        -- Update ..
        update EXERCISE
           set 
               DATE_REGISTERED = current_timestamp(3),
               NAME = vExerciseName,
               BODY_PART = vBodyPartName
         where
               ID = ObjectId;
    
        -- Verify ..
        call spGetIdForExercise (vExerciseName, vBodyPartName, localObjectId, ReturnCode);
        if (ObjectId = localObjectId) then
          set tStatus = 'SUCCESS';
        else
          set tStatus = 'FAILURE';
        end if;
    else
        set tStatus = 'IGNORED';
    end if;
    
    -- Log ..
    set SprocComment = concat('Update OBJECT to [', SignificantFields, '] where ID = ', ifNull(ObjectId, 'NULL'), ':  ', tStatus);
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
