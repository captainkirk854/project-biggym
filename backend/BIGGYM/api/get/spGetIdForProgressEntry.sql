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
                                         in vSetWeight double,
                                         in vSetDatestamp datetime,
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
                                    ' and SET_DATE = ''', vSetDatestamp, '''',
                                    ' and DEFINITIONid = ', vPlanDefinitionId
                                  );

    -- Get ..   
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

end$$
delimiter ;
