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
    declare SignificantFields varchar(256) default concat('SET_ORDINALITY=', vNew_SetOrdinality, ',SET_REPS=', vNew_SetReps, ',SET_WEIGHT=',vNew_SetWeight, ',DATE_PHYSICAL=', vNew_DatePhysical);
    declare ReferenceFields varchar(256) default concat('DEFINITIONid=', vPlanDefinitionId);
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
    
    -- Log ..
    set ReturnCode = tStatus;
    call spActionOnEnd (ObjectName, SpName, ObjectId, tStatus, SpComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

set @SetOrdinality =1;
set @SetReps = 10;
set @SetWeight = 65.5;
set @DatePhysical = '1995-01-25';
set @PlanDefinitionId = 1;

call spCreateProgressEntry (@SetOrdinality, 
                            @SetReps, 
                            @SetWeight, 
                            @DatePhysical, 
                            @PlanDefinitionId, 
                            @progressid, 
                            @returnCode, @errorCode, @stateCode, @errorMsg);
select @progressid, @returnCode;

*/
