/*
Name       : spErrorHandler
Object Type: STORED PROCEDURE
Dependency :
*/

use BIGGYM;

drop procedure if exists spErrorHandler;
delimiter $$
create procedure spErrorHandler(out ReturnCode int,
                                out SqlErrorCode int,
                                out SqlStateCode int,
                                out SqlErrorMsg varchar(512))
begin

  -- Variable Initialisation ..
 set ReturnCode = 0;
 set SqlErrorCode = 0;
 set SqlStateCode = 0;
 set SqlErrorMsg = '-';
 
 -- Get sql error diagnostics ..
 get DIAGNOSTICS CONDITION 1 @SqlState = RETURNED_SQLSTATE, @ErrCode = MYSQL_ERRNO, @Text = MESSAGE_TEXT;

 -- Assign for output ..
 if (@ErrCode > 0) then
    set ReturnCode = -1;
    set SqlErrorCode = @ErrCode;
    set SqlStateCode = @SqlState;
    set SqlErrorMsg = @Text;
 end if;
 
end$$
delimiter ;

/*
Sample Usage:

call spErrorHandler (@returnCode, @errorCode, @stateCode, @errorMsg);
select @returnCode, @errorCode, @stateCode, @errorMsg;
*/
