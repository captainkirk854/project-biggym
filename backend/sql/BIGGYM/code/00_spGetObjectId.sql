/*
Name       : spGetObjectId
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - any

            FUNCTION :
                - strcln

            STORED PROCEDURE :
                - spErrorHandler
                - spErrorHandler
                - spExecuteSQL
*/

use BIGGYM;

drop procedure if exists spGetObjectId;
delimiter $$
create procedure spGetObjectId(in ObjectName varchar(128),
                               in WhereClause varchar(1024),
                              out ObjectId smallint,
                              out ReturnCode int)
begin

    -- Declare ..
    declare ErrorCode int;
    declare ErrorMsg varchar(512);

    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare CONTINUE handler for SQLEXCEPTION
        begin
          call spErrorHandler (ReturnCode, ErrorCode, ErrorMsg);
          call spDebugLogger (database(), ObjectName, ReturnCode, ErrorCode, ErrorMsg);
        end;
        
    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Exception Handling -- 
    -- -------------------------------------------------------------------------
        
    -- Initialise ..
    set ObjectId = NULL;
    set @ObjectId = NULL;

    set @sql = concat('select ID into @ObjectId from ', strcln(ObjectName), ' where ', WhereClause, ' limit 1 ');
    call spExecuteSQL (@sql, NULL, NULL, NULL, NULL);
    set ObjectId = @ObjectId;
        
    -- If ID found, reset ReturnCode to 0 ..
    if (ObjectId is NOT NULL and ReturnCode != 0) then
        set ReturnCode = 0;
    end if; 

end$$
delimiter ;


/*
Sample Usage:

set @objectName='TRAINING_PLAN';
set @getIdWhereClause = concat('NAME = ''', vTrainingPlanName,  ''' and PROFILEid = ', vProfileId);
call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

set @objectName='EXERCISE';
set @getIdWhereClause = concat('NAME = ''', vExerciseName,  ''' and BODY_PART = ''', vBodyPartName, '''');
call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
*/
