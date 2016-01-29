use BIGGYM;


drop function if exists strcln; 
delimiter $$ 

create function strcln (inputString varchar(1024)) 
returns varchar(1024) 
begin

  -- Initialise .. 
  declare regExpClasses varchar(512) default '[ [:alnum:] [:digit:] [:blank:] [.=.] [...] [.~.] [.(.] [.).] [.[.] [.].] [._.] [.:.] [.-.] ]';
  declare pos, stringLength smallint default 1; 
  declare returnString varchar(1024) default ''; 
  declare c1 varchar(1); -- note if this is defined as char(1), then space becomes '' (!!?)
  
  -- Process ..
  set stringLength = char_length(inputString); 
  repeat 
    begin 
      set c1 = mid(inputString, pos, 1 );
      
      -- Use regular expression character classes to filter allowable characters ..
      if (c1 regexp regExpClasses) then
        set returnString=concat(returnString, c1); 
      end if; 
      set pos = pos + 1;
    end; 
  until pos > stringLength end repeat;
  
  -- Return modified string ..
  return returnString; 
end $$
 
delimiter ;

/*
Sample Usage:

select strcln('This works !!!!&&&$$!');
select strcln('This is allowable and simple as 1 2 3');
select strcln('These chaps "$"$"()"$ might disappear');
select strcln('''');
*/ 
