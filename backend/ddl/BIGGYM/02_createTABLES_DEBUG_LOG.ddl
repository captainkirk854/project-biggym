use BIGGYM;

drop table if exists DEBUG_LOG;
create table if not exists DEBUG_LOG
 (
  ID int  not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  OBJECT_NAME varchar(128) not null,
  SPROC_NAME varchar(128) not null,
  SPROC_COMMENT varchar(512) not null,
  SPROC_RETURN_CODE int not null,
  SQL_ERROR_CODE int not null,
  SQL_STATE_CODE int not null,
  SQL_ERROR_MESSAGE varchar(512) not null,
  primary key (ID)
 );
