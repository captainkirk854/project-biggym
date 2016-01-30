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
    declare SprocName varchar(128) default 'GetObjectId';
    declare SprocComment varchar(512) default '';
    declare ErrorCode int;
    declare ErrorState int;
    declare ErrorMsg varchar(512);

    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare CONTINUE handler for SQLEXCEPTION
        begin
          set SprocComment = concat('SEVERITY 1 EXCEPTION');
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
set @getIdWhereClause = "NAME = ''Get Bigger'' and PROFILEid = 1";
set @objectId = NULL;
set @returnCode = NULL;
call spGetObjectId (@objectName, @getIdWhereClause, @objectId,  @returnCode);
select @objectId,  @returnCode;

set @objectName='TRAINING_PLAN';
set @getIdWhereClause = concat('NAME = ''', vTrainingPlanName,  ''' and PROFILEid = ', vProfileId);
call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);

set @objectName='EXERCISE';
set @getIdWhereClause = concat('NAME = ''', vExerciseName,  ''' and BODY_PART = ''', vBodyPartName, '''');
call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
*/
