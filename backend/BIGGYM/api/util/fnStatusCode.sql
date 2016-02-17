use BIGGYM;


drop function if exists statuscode; 
delimiter $$ 

create function statuscode (finalStatusCode varchar(64)) 
returns varchar(64)
begin

  -- Initialise ..
  
  -- Process ..
  return 
        case
            when (strisnumeric(finalStatusCode)) then
                case
                                                --  +--------+--------+--------+--------+--------+--------+----
                    when finalStatusCode = 2  then 'input field value(s) already match - no update required'
                    when finalStatusCode = 1  then 'field values(s) already present in object'
                    
                    when finalStatusCode = 0  then 'success'

                    when finalStatusCode = -1 then 'illegal or null character(s) in one or more field value(s)'
                    when finalStatusCode = -2 then 'transaction made no change or caused duplicate field value(s)'
                    when finalStatusCode = -3 then 'anomalous data (likely duplicate) - transaction ignored'
                    when finalStatusCode = -4 then 'unexpected NULL value for one or more REFERENCEid(s)'
                    when finalStatusCode = -5 then 'database transaction problem'
                    when finalStatusCode = -6 then 'invalid date format used'
                    when finalStatusCode = -7 then 'unexpected NULL value for ObjectId and-or Reference Id(s)'
                                                --  +--------+--------+--------+--------+--------+--------+----
                else
                    concat('status code number of [', saynull(finalStatusCode), '] undefined')
                end
        else
            concat('status code number of [', saynull(finalStatusCode), '] undefined')
        end;
        
end $$
 
delimiter ;


/*
Sample Usage:

set @stCode='1';
select statuscode(@stCode);

set @stCode=1;
select statuscode(@stCode); 

set @stCode=0;
select statuscode(@stCode); 

set @stCode=-7;
select statuscode(@stCode);

set @stCode=-99;
select statuscode(@stCode);

set @stCode=NULL;
select statuscode(@stCode);

set @stCode='Turnips for tea';
select statuscode(@stCode);

*/
