/*
Name       : spUpdateExercise
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForExercise
*/

use BIGGYM;

drop procedure if exists spUpdateExercise;
delimiter $$
create procedure spUpdateExercise(in vUpdatable_ExerciseName varchar(128),
                                  in vUpdatable_BodyPartName varchar(128),
                               inout ObjectId mediumint unsigned,  
                                 out ReturnCode int,
                                 out ErrorCode int,
                                 out ErrorState int,
                                 out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'EXERCISE';
    declare SpName varchar(128) default 'spUpdateExercise';
    declare SignificantFields varchar(512) default concat('NAME=', saynull(vUpdatable_ExerciseName), 
                                                          ',BODY_PART=', saynull(vUpdatable_BodyPartName));
    declare ReferenceFields varchar(512) default concat('ID=', saynull(ObjectId));
    declare TransactionType varchar(16) default 'update';

    declare SpComment varchar(1024);
    declare tStatus varchar(64) default '-';
    declare localObjectId mediumint unsigned;
    
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

    -- Only "good" string input is allowed ..
    if(strisgood(vUpdatable_ExerciseName) and strisgood(vUpdatable_BodyPartName)) then
    
        -- Only proceed for not null objectId ..
        if (ObjectId is NOT NULL) then
        
            -- Attempt update ..
            call spGetIdForExercise (vUpdatable_ExerciseName, vUpdatable_BodyPartName, localObjectId, ReturnCode);
     
            if (ObjectId = localObjectId) then
                -- no update required ..
                set tStatus = 2;
                
            elseif (localObjectId is NULL) then
            
                -- Can update as no duplicate exists ..
                update EXERCISE
                   set 
                       C_LASTMOD = current_timestamp(3),
                       NAME = vUpdatable_ExerciseName,
                       BODY_PART = vUpdatable_BodyPartName
                 where
                       ID = ObjectId;
            
                -- Verify ..
                call spGetIdForExercise (vUpdatable_ExerciseName, vUpdatable_BodyPartName, localObjectId, ReturnCode);
                if (ObjectId = localObjectId) then
                    -- success ..
                    set tStatus = 0;
                else
                    -- transaction attempt made no change or caused duplicate ..
                    set tStatus = -2;
                    rollback;
                end if;
            else
                -- transaction attempt ignored as duplicate exists ..
                set tStatus = -3;
            end if;
        else
            -- unexpected NULL value for Object and/or reference Id ..
            set tStatus = -7;
        end if;
    else
        -- illegal or null characters found ..
        set tStatus = -1;
    end if;

    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;
