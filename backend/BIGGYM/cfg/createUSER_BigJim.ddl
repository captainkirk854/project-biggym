use mysql;
-- shouldn't need to do this -- create user BigJim@localhost;
grant all on BIGGYM.* to BigJim@localhost;

use BIGGYM;
grant all on BIGGYM to BigJim@localhost;
grant create on BIGGYM to BigJim@localhost;
flush privileges;
