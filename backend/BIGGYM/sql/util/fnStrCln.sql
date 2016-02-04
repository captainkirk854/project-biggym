use BIGGYM;


drop function if exists strcln; 
delimiter $$ 

create function strcln (inputString varchar(1024),
                        cleanMode varchar(5)) -- [CLEAN|SHOW] 
returns varchar(1024) 
begin

  -- SQL operators and special characters: @@, @, ||, -, *, /, <>, <, >, ,(comma), =, <=, >=, ~=, !=, ^=, (, ), ;
  
  -- Configurable ..
  declare regExpCharacters varchar(512) default '[.!.] [.=.] [...] [.~.] [.(.] [.).] [.[.] [.].] [._.] [.:.] [.-.] [.>.] [.<.]';
  declare regExpClasses varchar(512) default '[:alnum:] [:digit:] [:blank:]';
  declare badCharFlag char(1) default '*';
  
  -- Initialise ..
  declare regExpAllowableFilter varchar(1024) default concat( '[ ', regExpClasses, ' ',  regExpCharacters, ' ]');
  declare pos, stringLength smallint unsigned default 1; 
  declare returnString varchar(1024) default ''; 
  declare c1 varchar(1); -- note if this is defined as char(1), then space becomes '' (!!?)

  -- Process ..
  if (inputString is NOT NULL) then
        set stringLength = char_length(inputString); 
        repeat 
            begin 
              set c1 = mid(inputString, pos, 1 );
              
              -- Use regular expression to filter allowable characters ..
              if (c1 regexp regExpAllowableFilter) then
                set returnString = concat(returnString, c1); 
              else
                if(lower(cleanMode) = 'show') then
                    set returnString = concat(returnString, badCharFlag);
                end if;
              end if; 
              set pos = pos + 1;
            end; 
        until pos > stringLength end repeat;

        -- Return modified string ..
        return returnString;
   else
        return inputString;
   end if;
end $$
 
delimiter ;

/*
Sample Usage:

select strcln('This works !!!!&&&$$!', 'clean');
select strcln('This works !!!!&&&$$!', 'show');

select strcln('This is allowable and simple as 1 2 3', 'clean');
select strcln('This is allowable and simple as 1 2 3', 'show');

select strcln('These chaps "$"$"()"$ might disappear', 'clean');
select strcln('These chaps "$"$"()"$ might disappear', 'show');

select strcln('''', 'clean');
select strcln('''', 'show');

select strcln(NULL, 'clean');
select strcln(NULL, 'show');
*/ 
