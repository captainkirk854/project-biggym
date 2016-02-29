/*
Name       : spActionOnEnd
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - DEBUG_LOG

            FUNCTION :
                - saynull
                - statuscode

            STORED PROCEDURE :
                - spDebugLogger
*/

use BIGGYM;

drop procedure if exists spActionOnEnd;
delimiter $$
create procedure spActionOnEnd(in ObjectName varchar(128),
                               in SprocName varchar(128),
                               in ObjectId mediumint unsigned,
                               in FinalStatus varchar(64),
                               in FinalComment varchar(1024),
                               in ReturnCode int,
                               in ErrorCode int,
                               in ErrorState int,
                               in ErrorMsg varchar(512))
begin
    
    -- Initialise ..
    declare delim char(3) default '-:-';
    set FinalComment = concat(FinalComment, delim, 'OBJECT ID = <', saynull(ObjectId), '>');
    set FinalComment = concat(FinalComment, delim, statuscode(FinalStatus));

    -- Action ..
    call spDebugLogger (database(), ObjectName, SprocName, FinalComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);    

end$$
delimiter ;


/*
Sample Usage:
*/
