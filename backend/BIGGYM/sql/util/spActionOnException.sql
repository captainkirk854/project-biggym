/*
Name       : spActionOnException
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - DEBUG_LOG

            FUNCTION :

            STORED PROCEDURE :
                - spErrorHandler
                - spDebugLogger
*/

use BIGGYM;

drop procedure if exists spActionOnException;
delimiter $$
create procedure spActionOnException(in ObjectName varchar(128),
                                     in SprocName varchar(128),
                                     in SeverityLevel varchar(4),
                                     in ExceptionComment varchar(512),
                                    out ReturnCode int,
                                    out ErrorCode int,
                                    out ErrorState int,
                                    out ErrorMsg varchar(512))
begin
    
    -- Initialise ..
    declare CommentToLog varchar(512) default concat('SEVERITY ', SeverityLevel, ' EXCEPTION: ', ExceptionComment);
    
    -- Action ..
    call spErrorHandler (ReturnCode, ErrorCode, ErrorState, ErrorMsg);
    call spDebugLogger (database(), ObjectName, SprocName, CommentToLog, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:
*/