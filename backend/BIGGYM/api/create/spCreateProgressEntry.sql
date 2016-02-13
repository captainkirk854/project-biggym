/*
Name       : spCreateProgressEntry
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROGRESS
            
            STORED PROCEDURE :
                - spActionOnException
                - spActionOnStart
                - spActionOnEnd
*/

use BIGGYM;

drop procedure if exists spCreateProgressEntry;
delimiter $$
create procedure spCreateProgressEntry(in vNew_SetOrdinality tinyint unsigned,
                                       in vNew_SetReps tinyint unsigned,
                                       in vNew_SetWeight float,
                                       in vNew_DatePhysical datetime,
                                       in vPlanDefinitionId mediumint unsigned,
                                      out ObjectId mediumint unsigned,
                                      out ReturnCode int,
                                      out ErrorCode int,
                                      out ErrorState int,
                                      out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROGRESS';
    declare SpName varchar(128) default 'spCreateProgressEntry';
    declare SignificantFields varchar(256) default concat('SET_ORDINALITY=', saynull(vNew_SetOrdinality), 
                                                          ',SET_REPS=', saynull(vNew_SetReps), 
                                                          ',SET_WEIGHT=', saynull(vNew_SetWeight), 
                                                          ',DATE_PHYSICAL=', saynull(vNew_DatePhysical));
    declare ReferenceFields varchar(256) default concat('DEFINITIONid=', saynull(vPlanDefinitionId));
    declare TransactionType varchar(16) default 'insert';

    declare SpComment varchar(512);
    declare tStatus varchar(64) default '-';
    
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


    -- Check if date uses valid format (YY-mm-dd) ..
    if (date(vNew_DatePhysical) is NOT NULL and (vNew_DatePhysical != '0000-00-00')) then

        -- Attempt create ..  
        insert into 
                PROGRESS
                ( 
                 SET_ORDINALITY, 
                 SET_REPS, 
                 SET_WEIGHT, 
                 DATE_PHYSICAL,
                 DEFINITIONid
                )
                values
                (
                 vNew_SetOrdinality,
                 vNew_SetReps,
                 vNew_SetWeight,
                 vNew_DatePhysical,
                 vPlanDefinitionId
                );

        -- success ..
        set tStatus = 0;
        call spGetIdForProgressEntry (vNew_SetOrdinality, vNew_SetReps, vNew_SetWeight, vNew_DatePhysical, vPlanDefinitionId, ObjectId, ReturnCode);
    else
        -- invalid date format used ..
        set tStatus = -6;  
    end if;
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;
