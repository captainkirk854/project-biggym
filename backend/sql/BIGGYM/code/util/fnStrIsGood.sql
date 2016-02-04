use BIGGYM;


drop function if exists strisgood; 
delimiter $$ 

create function strisgood (inputString varchar(1024)) 
returns boolean
begin

  -- Initialise ..
  declare returnString varchar(1024) default '';
  
  -- Process ..
  if(length(inputString) = length(strcln(inputString, 'clean'))) then
    return true;
  else
    return false;
  end if;
end $$
 
delimiter ;


/*
Sample Usage:

set @goodString = 'xyz';
set @naughtyString = 'x!!yz';
select 
    case
        when strisgood(@goodString) = true then 'Good'
    else
        'Naughty'
    end GOOD,
    case
        when strisgood(@naughtyString) = true then 'Good'
    else
        'Naughty'
    end NAUGHTY  
    ;
    
*/