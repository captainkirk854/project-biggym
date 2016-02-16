/*
Name       : spRegisterExercise
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - EXERCISE
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spSimpleLog
                - spCreateExercise
                - spUpdateExercise
*/

use BIGGYM;

drop procedure if exists spRegisterExercise;
delimiter $$
create procedure spRegisterExercise(in vNewOrUpdatable_ExerciseName varchar(128),
                                    in vNewOrUpdatable_BodyPartName varchar(128),   
                                 inout ObjectId mediumint unsigned,
                                   out ReturnCode int,
                                   out ErrorCode int,
                                   out ErrorState int,
                                   out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default '-various-';
    declare SpName varchar(128) default 'spRegisterExercise';
    declare SignificantFields varchar(256) default concat('NAME=', saynull(vNewOrUpdatable_ExerciseName),
                                                          ',BODY_PART=', saynull(vNewOrUpdatable_BodyPartName));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId));
    declare TransactionType varchar(16) default 'insert-update'; 
    
    declare SpComment varchar(512);
    declare tStatus varchar(64) default 0;
       
    -- Initialise ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    call spActionOnStart (TransactionType, ObjectName, SignificantFields, ReferenceFields, SpComment);
    call spSimpleLog (ObjectName, SpName, concat('--[START] parameters: ', SpComment), ReturnCode, ErrorCode, ErrorState, ErrorMsg); 
 
    -- Action ..
    if (ObjectId is NULL) then
        -- create ..    
        call spCreateExercise (vNewOrUpdatable_ExerciseName, vNewOrUpdatable_BodyPartName, ObjectId, ReturnCode, ErrorCode,ErrorState, ErrorMsg);
    else
        -- update
        call spUpdateExercise (vNewOrUpdatable_ExerciseName, vNewOrUpdatable_BodyPartName, ObjectId, ReturnCode, ErrorCode,ErrorState, ErrorMsg);
    end if;

    if(ErrorCode != 0) then
        -- unexpected database transaction problem encountered
        set tStatus = -5;
    else
        set tStatus = ReturnCode;
    end if;

    -- Log ..
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, '----[END]', ReturnCode, ErrorCode, ErrorState, ErrorMsg); 

end$$
delimiter ;
