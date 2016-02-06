use mysql;
grant all on tap.* to BigJim@localhost;

use tap;
grant all on tap to BigJim@localhost;
grant create on tap to BigJim@localhost;
flush privileges;
