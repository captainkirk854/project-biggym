/*
Name       : spGetIdForProgressEntry
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROGRESS
            
            STORED PROCEDURE :
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spGetIdForProgressEntry;
delimiter $$
create procedure spGetIdForProgressEntry(in vSetOrdinality tinyint unsigned,
                                         in vSetReps tinyint unsigned,
                                         in vSetWeight float,
                                         in vDatePhysical datetime,
                                         in vPlanDefinitionId mediumint unsigned,
                                        out ObjectId mediumint unsigned,
                                        out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROGRESS';
    
    -- Prepare ..
    set @getIdWhereClause = concat(     ' SET_ORDINALITY = ', vSetOrdinality,
                                    ' and SET_REPS = ', vSetReps,
                                    ' and SET_WEIGHT = ', vSetWeight,
                                    ' and DATE_PHYSICAL = ''', vDatePhysical, '''',
                                    ' and DEFINITIONid = ', vPlanDefinitionId
                                  );
    
    -- Get ..   
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;

/*
Sample Usage:

set @SetOrdinality =1;
set @SetReps = 10;
set @SetWeight = 65.5;
set @DatePhysical = '1995-01-25';
set @PlanDefinitionId = 1;

call spGetIdForProgressEntry (@SetOrdinality, 
                              @SetReps, 
                              @SetWeight, 
                              @DatePhysical, 
                              @PlanDefinitionId, 
                              @progressid, 
                              @returnCode);
select @progressid, @returnCode;
*/
