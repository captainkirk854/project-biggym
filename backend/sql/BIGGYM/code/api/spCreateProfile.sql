/*
Name       : spCreateProfile
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spGetIdForProfile
*/

use BIGGYM;

drop procedure if exists spCreateProfile;
delimiter $$
create procedure spCreateProfile(in vNew_ProfileName varchar(32),
                                 in vPersonId mediumint unsigned,
								out ObjectId mediumint unsigned,
                                out ReturnCode int,
                                out ErrorCode int,
                                out ErrorState int,
                                out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare SprocName varchar(128) default 'spCreateProfile';
    
    declare SignificantFields varchar(256) default concat('NAME = <', vNew_ProfileName, '>');
    declare WhereCondition varchar(256) default concat('where PERSONid = ', vPersonId);
    declare SprocComment varchar(512) default concat('insert into object field list [', SignificantFields, '] ', WhereCondition);
    
    declare tStatus varchar(64) default '-';
 
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
    declare EXIT handler for SQLEXCEPTION
        begin
           set SprocComment = concat('SEVERITY 1 EXCEPTION: ', SprocComment);
          call spErrorHandler (ReturnCode, ErrorCode, ErrorState, ErrorMsg);
          call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        end;

    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Error Handling --
    -- -------------------------------------------------------------------------

    -- Clean character input ..
    set vNew_ProfileName = strcln(vNew_ProfileName);

    -- Check for valid input ..
    if(length(vNew_ProfileName) != 0) then

		-- Attempt profile registration ..
		call spGetIdForProfile (vNew_ProfileName, vPersonId, ObjectId, ReturnCode);
		if (ObjectId is NULL) then
			insert into 
					PROFILE
					(
					 NAME,
					 PERSONid
					)
					values
					(
					 vNew_ProfileName,
					 vPersonId
					);
			set tStatus = 'SUCCESS';
			call spGetIdForProfile (vNew_ProfileName, vPersonId, ObjectId, ReturnCode);
		else
			set tStatus = 'FIELD VALUE(S) ALREADY PRESENT';
		end if;
    else
        set tStatus = 'ONLY ILLEGAL CHARACTERS IN ONE OR MORE FIELD VALUE(S)';
        set ReturnCode = -1;
    end if;
    
    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(ObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);

end$$
delimiter ;


/*
Sample Usage:

set @personId=10;
call spCreateProfile ('Faceman', @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @personId=10;
call spCreateProfile ('cara di hombre', @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg;

set @personId=9;
call spCreateProfile ('cara di hombre', @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg);
select @personId, @profileId, @returnCode, @errorCode, @stateCode, @errorMsg;
*/
