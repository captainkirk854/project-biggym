use BIGGYM;


drop function if exists strindex; 
delimiter $$ 

create function strindex (InputString varchar(2048), 
                          Delim varchar(16),
                          IndexPos tinyint) 
returns varchar(2048)
begin

    -- Initialise ..
    set @pos = IndexPos - 1;
    
    set @length_to_pos1 = length(substring_index(InputString, Delim, @pos));
    if (@length_to_pos1 > 0) then
        set @length_to_pos1 = @length_to_pos1 + 1 ;
    end if;

    set @pos = @pos + 1;
    set @length_to_pos2 = length(substring_index(InputString, Delim, @pos));

    -- Process ..
    return trim(mid(InputString, @length_to_pos1 + length(Delim), @length_to_pos2 - @length_to_pos1));
    
end $$
 
delimiter ;