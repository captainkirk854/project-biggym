/*
Name       : spErrorHandler
Object Type: STORED PROCEDURE
Dependency :
*/

use BIGGYM;

drop procedure if exists spErrorHandler;
delimiter $$
create procedure spErrorHandler(out ReturnCode int,
                                out ErrorCode int,
                                out ErrorMsg varchar(512))
begin

  -- Variable Initialisation ..
 set ReturnCode = 0;
 set ErrorCode = 0;
 set ErrorMsg = '-';
 
 -- Get sql error diagnostics ..
 get DIAGNOSTICS CONDITION 1 @Sqlstate = RETURNED_SQLSTATE, @Errno = MYSQL_ERRNO, @Text = MESSAGE_TEXT;

 -- Assign for output ..
 if (@errno > 0) then
    set ReturnCode = -1;
    set ErrorCode = @errno;
    set ErrorMsg = concat('Error: [', @Errno, '] State: [', @Sqlstate, '] Text: [', @Text, ']');
 end if;
 
end$$
delimiter ;

/*
Sample Usage:

call spErrorHandler (@returnCode, @errorCode, @errorMsg);
select @returnCode, @errorCode, @errorMsg;
*/
