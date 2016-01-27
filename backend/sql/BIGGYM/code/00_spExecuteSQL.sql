/*
Name       : spExecuteSQL
Object Type: STORED PROCEDURE
Dependency :
*/

use BIGGYM;

drop procedure if exists spExecuteSQL;
delimiter $$
create procedure spExecuteSQL(in STMT varchar(2048),
                              in VAR1 varchar(128),
                              in VAR2 varchar(128),
                              in VAR3 varchar(128),
                              in VAR4 varchar(128))
begin

  -- Variable Initialisation ..
  set @stmt = STMT;
  set @v1 = VAR1;
  set @v2 = VAR2;
  set @v3 = VAR3;
  set @v4 = VAR4;
  
  -- Prepare ..
  prepare stmt from @stmt;
  
  -- Execute ..
  if (@v1 is NOT NULL and @v2 is NOT NULL and @v3 is NOT NULL and @v4 is NOT NULL ) then
    execute stmt using @v1, @v2, @v3, @v4;
  elseif (@v1 is NOT NULL and @v2 is NOT NULL and @v3 is NOT NULL and @v4 is NULL ) then
    execute stmt using @v1, @v2, @v3;
  elseif (@v1 is NOT NULL and @v2 is NOT NULL and @v3 is NULL and @v4 is NULL ) then
    execute stmt using @v1, @v2;
  elseif (@v1 is NOT NULL and @v2 is NULL and @v3 is NULL and @v4 is NULL ) then
    execute stmt using @v1;
  else
    execute stmt;
  end if;
  deallocate prepare stmt;
  
end;$$
delimiter ;


-- Sample Usage --
set @sql='select 1,2';
call spExecuteSQL (@sql, NULL, NULL, NULL, NULL);

set @sql='select "A FLY" into @insect';
call spExecuteSQL (@sql, NULL, NULL, NULL, NULL);
select concat('There is a ', @insect, ' in my soup');

set @sql='select sqrt(pow(?,2)) A_SIDE';
call spExecuteSQL (@sql, 3, NULL, NULL, NULL);

set @sql='select sqrt(pow(?,2) + pow(?,2)) as HYPOTENUSE';
call spExecuteSQL (@sql, 3, 4, NULL, NULL);

set @sql='select sqrt(pow(?,2) + pow(?,2)) into @hypotenuse';
call spExecuteSQL (@sql, 3, 4, NULL, NULL);
select @hypotenuse;
-- Sample Usage --

