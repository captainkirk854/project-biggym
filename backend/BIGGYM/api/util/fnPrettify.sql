use BIGGYM;


drop function if exists prettify; 
delimiter $$ 

create function prettify (inputStringList varchar(1024), 
                              inputDelimiter varchar(10)) 
returns varchar(2048)
begin

  -- Initialise ..
  declare fieldStart char(1) default '<';
  declare fieldEnd char(1) default '>';
  
  -- Process ..
  return concat(fieldStart, replace(inputStringList, inputDelimiter, concat(fieldEnd, inputDelimiter, fieldStart)), fieldEnd);
end $$
 
delimiter ;


/*
Sample Usage:

set @list='NAME=PULLUPS,BODY_PART=ARMS';
select prettify(@list, ',');    

set @list='NAME=PULLUPS,       BODY_PART=    ARMS';
select prettify(@list, ','); 
*/
