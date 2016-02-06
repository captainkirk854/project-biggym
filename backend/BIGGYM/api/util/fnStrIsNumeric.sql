use BIGGYM;


drop function if exists strisnumeric; 
delimiter $$ 

create function strisnumeric (inputString varchar(1024)) 
returns boolean 
begin

    -- Configurable ..
    declare decimalPoint char(1) default '.';
    declare powerOf char(1) default 'E';
    declare regExpCharacters varchar(512) default '[.+.] [.-.]';
    declare regExpClasses varchar(512) default '[:digit:]';

    -- Initialise .. 
    declare regExpAllowableFilter varchar(512) default concat('[ ', regExpClasses, regExpCharacters, '[.', decimalPoint, '.] [.', powerOf, '.] ]');
    declare pos, stringLength smallint unsigned default 1;
    declare dpCount, poCount smallint unsigned default 0;
    declare c1 varchar(1);
    
    declare isNonNumeric boolean default false;
    
    -- Process ..
    if (inputString is NOT NULL) then
        set stringLength = char_length(inputString); 
        repeat 
            begin 
              set c1 = mid(upper(inputString), pos, 1);
              
              -- Use regular expression character classes to filter allowable numeric characters ..
              if (not c1 regexp regExpAllowableFilter) then
                set isNonNumeric = true;
              end if;
              
              -- Count specials ..
              if(c1 = decimalPoint) then
                set dpCount = dpCount + 1;
              end if;
              if(c1 = powerOf) then
                set poCount = poCount + 1;
              end if;
              
              set pos = pos + 1;
            end; 
        until pos > stringLength end repeat;
    else
        set isNonNumeric = true;
    end if;
   
   -- Only allow 1 decimal point or 1 power of ....
   if(dpCount > 1 or poCount > 1) then
        set isNonNumeric = true;
    end if;
   
   -- Conclude ..
   if(isNonNumeric) then
    return false;
   else
    return true;
   end if;
   
end $$
 
delimiter ;

/*
Sample Usage:

select strisnumeric('123');
select strisnumeric('abc');
select strisnumeric('ab1c');
select strisnumeric('-123');
select strisnumeric('+123');
select strisnumeric('+-123');
select strisnumeric('12.4453');
select strisnumeric('12.4453E5');
select strisnumeric('E12.44535');
select strisnumeric('E12.44E535');
select strisnumeric('12.4453F5');
select strisnumeric('12.4453.5');
select strisnumeric('is this sentence numerical?');
select strisnumeric('This is allowable and simple as 1 2 3');
select strisnumeric('''');
select strisnumeric(NULL);
*/