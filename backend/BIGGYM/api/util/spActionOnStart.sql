/*
Name       : spActionOnStart
Object Type: STORED PROCEDURE
Dependency :
            TABLE:
                - DEBUG_LOG

            FUNCTION :

            STORED PROCEDURE :
                - spDebugLogger
*/

use BIGGYM;

drop procedure if exists spActionOnStart;
delimiter $$
create procedure spActionOnStart(in TransactionType varchar(16),
                                 in ObjectName varchar(128),
                                 in SignificantFields varchar(512),
                                 in ReferenceFields varchar(512),
                                out FinalComment varchar(1024))
begin
    
    -- Initialise ..
    declare delim char(1) default ',';
    
    -- Build comment ..
    set FinalComment = concat(case when lower(TransactionType) = 'insert' then 'insert into' else lower(TransactionType) end, ' [', 
                       ObjectName, 
                       '] object field(s) ', 
                       '[', 
                       prettify(SignificantFields, delim), 
                       '] ', 
                       'using reference field(s) ', 
                       '[', 
                       prettify(ReferenceFields, delim), 
                       ']');
end$$
delimiter ;


/*
Sample Usage:
    call spActionOnStart ('insert', 'ploppy', 'NAME=PULLUPS,A=B', 'na', @finalcomment);
    select @finalcomment;

    call spActionOnStart ('update', 'ploppy', 'NAME=PULLUPS,A=B', 'na', @finalcomment);
    select @finalcomment;
*/
