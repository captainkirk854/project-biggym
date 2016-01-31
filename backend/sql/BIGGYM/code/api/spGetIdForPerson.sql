/*
Name       : spGetIdForPerson
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PERSON
            
            STORED PROCEDURE :
                - spGetObjectId
*/

use BIGGYM;

drop procedure if exists spGetIdForPerson;
delimiter $$
create procedure spGetIdForPerson(in vFirstName varchar(128),
     			                  in vLastName varchar(128),
			                      in vBirthdate date,
			                     out ObjectId smallint,
			                     out ReturnCode int)
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PERSON';

    -- Get Person Id ..
    set @getIdWhereClause = concat('FIRST_NAME = ''', vFirstName, ''' and LAST_NAME = ''', vLastName,  ''' and BIRTH_DATE = ''', vBirthdate, '''');
    call spGetObjectId (ObjectName, @getIdWhereClause, ObjectId,  ReturnCode);
    
end$$
delimiter ;


/*
Sample Usage:

call spGetIdForPerson ('Dirk', 'Benedict', '1945-03-01', @id, @returnCode);
select @id, @returnCode;
*/
