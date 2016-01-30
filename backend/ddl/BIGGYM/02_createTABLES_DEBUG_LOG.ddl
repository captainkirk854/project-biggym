use BIGGYM;

drop table if exists DEBUG_LOG;
create table if not exists DEBUG_LOG
 (
  ID int  not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  OBJECT_NAME varchar(128) not null,
  RETURN_CODE int not null,
  ERROR_CODE int not null,
  ERROR_MESSAGE varchar(512) not null,
  primary key (ID)
 );
