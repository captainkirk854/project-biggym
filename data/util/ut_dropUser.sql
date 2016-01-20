select 
       concat('drop user ','\'', user, '\'', '@', '\'', host, '\'', ';') 
  from 
       mysql.user 
 where 
       user = 'dad' ;
