/*
Name       : spSimpleLog
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - DEBUG_LOG

            FUNCTION :

            STORED PROCEDURE :
                - spDebugLogger
*/

use BIGGYM;

drop procedure if exists spSimpleLog;
delimiter $$
create procedure spSimpleLog(in ObjectName varchar(128),
                             in SprocName varchar(128),
                             in LogComment varchar(512),
						     in ReturnCode int,
                             in ErrorCode int,
                             in ErrorState int,
                             in ErrorMsg varchar(512))
begin
    
    -- Initialise ..

    -- Action ..
    call spDebugLogger (database(), ObjectName, SprocName, LogComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);    

end$$
delimiter ;


/*
Sample Usage:
*/
