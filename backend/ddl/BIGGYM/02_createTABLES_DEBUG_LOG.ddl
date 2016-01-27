use BIGGYM;

drop table if exists DEBUG_LOG;
create table if not exists DEBUG_LOG
 (
  ID int  not null auto_increment,
  DATE_REGISTERED timestamp default current_timestamp not null,
  OBJECT_NAME varchar(128) not null,
  RETURN_CODE int not null,
  ERROR_CODE int not null,
  ERROR_MESSAGE varchar(512) not null,
  primary key (ID)
 );
