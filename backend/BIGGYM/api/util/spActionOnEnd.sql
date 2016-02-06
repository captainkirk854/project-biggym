/*
Name       : spActionOnEnd
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - DEBUG_LOG

            FUNCTION :

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
                               in FinalComment varchar(512),
                               in ReturnCode int,
                               in ErrorCode int,
                               in ErrorState int,
                               in ErrorMsg varchar(512))
begin
    
    -- Initialise ..
    declare delim char(3) default '-:-';
    
    if(strisnumeric(FinalStatus))then
        set FinalStatus = 
            case
                when FinalStatus = 0  then 'success'
                when FinalStatus = 1  then 'field values(s) already present in object'
                when FinalStatus = 2  then 'input field value(s) already match - no update required'
                when FinalStatus = -1 then 'illegal character(s) in one or more input field value(s)'
                when FinalStatus = -2 then 'unexpected occurrence of more than one row of input field value(s)'
                when FinalStatus = -3 then 'anomalous data - transaction ignored'
                when FinalStatus = -4 then 'unexpected NULL value for one or more REFERENCEid(s)'
                when FinalStatus = -5 then 'unexpected database transaction problem encountered'
                when FinalStatus = -6 then 'invalid date format used'
            else
                concat('status number of [', FinalStatus, '] undefined')
            end;    
    end if;
    
    set FinalComment = concat(FinalComment, delim, 'OBJECT ID = <', ifNull(ObjectId, 'NULL'), '>');
    set FinalComment = concat(FinalComment, delim, FinalStatus);

    -- Action ..
    call spDebugLogger (database(), ObjectName, SprocName, FinalComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);    

end$$
delimiter ;


/*
Sample Usage:
*/
