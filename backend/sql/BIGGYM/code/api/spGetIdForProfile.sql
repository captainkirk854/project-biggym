/*
Name       : spGetIdForProfile
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROFILE
            
            STORED PROCEDURE :
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spGetIdForProfile;
delimiter $$
create procedure spGetIdForProfile(in vProfileName varchar(32),
                                   in vPersonId smallint,
                                  out ObjectId smallint,
                                  out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    
    -- Get Profile Id ..
    set @getIdWhereClause = concat('NAME = ''', vProfileName,  ''' and PERSONid = ', vPersonId);
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
    
end$$
delimiter ;


/*
Sample Usage:

call spGetIdForProfile ('Faceman', 10, @id, @returnCode);
select @id, @returnCode;
*/
