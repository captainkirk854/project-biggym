use BIGGYM;

drop table if exists PERSON;
create table if not exists PERSON
 (
  ID mediumint unsigned not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  FIRST_NAME varchar(32) not null,
  LAST_NAME varchar(32) not null,
  BIRTH_DATE date not null,
  primary key (ID)
 );

drop table if exists PROFILE;
create table if not exists PROFILE
 (
  ID mediumint unsigned not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  NAME varchar(32) not null DEFAULT 'UNDEFINED CHAMPION',
  PERSONid mediumint unsigned not null,
  primary key (ID)
 );

drop table if exists EXERCISE;
create table if not exists EXERCISE
 (
  ID mediumint unsigned not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  NAME varchar(128) not null,
  BODY_PART varchar(128) not null,
  primary key (ID)
 );

drop table if exists TRAINING_PLAN;
create table if not exists TRAINING_PLAN
 (
  ID mediumint unsigned not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  NAME varchar(128) not null,
  PRIVATE enum('YES','NO') default 'NO' not null,
  PROFILEid mediumint unsigned not null,
  primary key (ID)
 );

drop table if exists TRAINING_PLAN_DEFINITION;
create table if not exists TRAINING_PLAN_DEFINITION
 (
  ID mediumint unsigned not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  PLANid mediumint unsigned not null,
  EXERCISEid mediumint unsigned not null,
  EXERCISE_WEEK tinyint unsigned default 1 null,
  EXERCISE_DAY enum('1','2','3','4','5','6','7') null,
  EXERCISE_ORDINALITY tinyint unsigned null,
  primary key (ID)
 );

drop table if exists PROGRESS;
create table if not exists PROGRESS
 (
  ID mediumint unsigned  not null auto_increment,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  DEFINITIONid mediumint unsigned not null,
  SET_ORDINALITY tinyint unsigned default 1 null,
  SET_REPS tinyint unsigned default 0 not null,
  SET_WEIGHT float default 0 not null,
  DATE_PHYSICAL datetime not null,
  primary key (ID)
 );