/*
Name       : spUpdateProgressEntry
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROGRESS
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
                - spGetIdForProgressEntry
*/

use BIGGYM;

drop procedure if exists spUpdateProgressEntry;
delimiter $$
create procedure spUpdateProgressEntry(in vUpdatable_SetOrdinality tinyint unsigned,
                                       in vUpdatable_SetReps tinyint unsigned,
                                       in vUpdatable_SetWeight float,
                                       in vUpdatable_DateOfSet datetime,
                                       in vPlanDefinitionId mediumint unsigned,
                                    inout ObjectId mediumint unsigned,
                                      out ReturnCode int,
                                      out ErrorCode int,
                                      out ErrorState int,
                                      out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROGRESS';
    declare SpName varchar(128) default 'spUpdateProgressEntry';
    declare SignificantFields varchar(256) default concat('SET_ORDINALITY=', saynull(vUpdatable_SetOrdinality), 
                                                          ',SET_REPS=', saynull(vUpdatable_SetReps), 
                                                          ',SET_WEIGHT=', saynull(vUpdatable_SetWeight), 
                                                          ',SET_DATE=', saynull(vUpdatable_DateOfSet));
    declare ReferenceFields varchar(256) default concat('ID=', saynull(ObjectId),
                                                        ',DEFINITIONid=', saynull(vPlanDefinitionId));
    declare TransactionType varchar(16) default 'update';

    declare SpComment varchar(512);
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

    -- Only proceed for not null objectId and reference Id(s)..
    if (ObjectId is NOT NULL and vPlanDefinitionId is NOT NULL) then

        -- Check if date uses valid format (YY-mm-dd) ..
        if (date(vUpdatable_DateOfSet) is NOT NULL and (vUpdatable_DateOfSet != '0000-00-00')) then
            call spGetIdForProgressEntry (vUpdatable_SetOrdinality, vUpdatable_SetReps, vUpdatable_SetWeight, vUpdatable_DateOfSet, vPlanDefinitionId, localObjectId, ReturnCode);
            
            if (ObjectId = localObjectId) then
                -- no update required ..
                set tStatus = 2;
            
            elseif (localObjectId is NULL) then
                -- Can update as no duplicate exists ..
                update PROGRESS
                   set 
                       SET_ORDINALITY = vUpdatable_SetOrdinality, 
                       SET_REPS = vUpdatable_SetReps, 
                       SET_WEIGHT = vUpdatable_SetWeight, 
                       SET_DATE = vUpdatable_DateOfSet
                where   
                       ID = ObjectId
                  and
                       DEFINITIONid = vPlanDefinitionId;

                -- Verify ..
                set tStatus = 0;
                call spGetIdForProgressEntry (vUpdatable_SetOrdinality, vUpdatable_SetReps, vUpdatable_SetWeight, vUpdatable_DateOfSet, vPlanDefinitionId, localObjectId, ReturnCode);
                if (ObjectId = localObjectId) then
                    -- success ..
                    set tStatus = 0;
                else
                    -- transaction attempt made no change or caused duplicate ..
                    set tStatus = -2;
                end if;
            else
                -- transaction attempt ignored as duplicate exists ..
                set tStatus = -3;
            end if; 
        else
            -- invalid date format used ..
            set tStatus = -6;  
        end if;
    else
        -- unexpected NULL value for Object and/or reference Id ..
        set tStatus = -7;
    end if; 
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;
