use BIGGYM;


drop function if exists saynull; 
delimiter $$ 

create function saynull (inputObject varchar(1024)) 
returns varchar(1024)
begin

  -- Initialise ..
  declare NullFlag char(4) default 'null';
  
  -- Process ..
  return ifNull(inputObject, NullFlag);
end $$
 
delimiter ;


/*
Sample Usage:

set @list='HEAD';
select saynull(@list);    

set @list=NULL;
select saynull(@list);

*/
