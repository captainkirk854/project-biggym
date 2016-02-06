use mysql;
grant all on BIGGYM.* to BigJim@localhost;

use BIGGYM;
grant all on BIGGYM to BigJim@localhost;
grant create on BIGGYM to BigJim@localhost;
flush privileges;
