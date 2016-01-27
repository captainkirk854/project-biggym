/*
Name       : spDebugLogger
Object Type: STORED PROCEDURE
Dependency : strcln (FUNCTION), spExecuteSQL (STORED PROCEDURE), DEBUG_LOG(TABLE)
*/

use BIGGYM;

drop procedure if exists spDebugLogger;
delimiter $$
create procedure spDebugLogger(in DebugLoggingDatabase varchar(128),
                               in ObjectName varchar(128),
                               in ReturnCode int,
                               in ErrorCode int,
                               in ErrorMsg varchar(512))
begin

    declare debugLoggingTable varchar(128) default 'DEBUG_LOG';

    if (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE' and TABLE_SCHEMA = DebugLoggingDatabase and TABLE_NAME = debugLoggingTable) then
    
        set @dml = concat('insert into ', 
                                        DebugLoggingDatabase, '.',  debugLoggingTable, 
                              ' (',
                                    'OBJECT_NAME,',
                                    'RETURN_CODE,',
                                    'ERROR_CODE,',
                                    'ERROR_MESSAGE'
                              ' )',
                          ' values ', 
                              ' (', 
                                    '''',strcln(ObjectName),'''', ',',
                                         ReturnCode,      ',',
                                         ErrorCode,       ',', 
                                    '''',strcln(ErrorMsg),'''', 
                              ' )'
                         );
                      
        call spExecuteSQL (@dml, NULL, NULL, NULL, NULL);
        
    end if;

end$$
delimiter ;


-- Sample Usage --
set @objectName='MYTABLE';
set @returnCode=-1;
set @errorCode=-999;
set @errorMsg='We have got some problems';
call spDebugLogger (database(), @objectName, @returnCode, @errorCode, @errorMsg);

call spDebugLogger (database(), 'ANOTHER_TABLE', 1223, 133, 'OH DEAR .. OH DEAR OH DEAR');
-- Sample Usage --