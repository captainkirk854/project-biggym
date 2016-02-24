use BIGGYM;

drop table if exists EXERCISE;
create table if not exists EXERCISE
 (
  ID mediumint unsigned not null auto_increment,
  NAME varchar(128) not null,
  BODY_PART varchar(128) not null,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  primary key (ID)
 );

drop table if exists PERSON;
create table if not exists PERSON
 (
  ID mediumint unsigned not null auto_increment,
  FIRST_NAME varchar(32) not null,
  LAST_NAME varchar(32) not null,
  BIRTH_DATE date not null,
  GENDER enum('M','F','-') not null default '-',
  BODY_HEIGHT float null,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  primary key (ID)
 );

drop table if exists PROFILE;
create table if not exists PROFILE
 (
  ID mediumint unsigned not null auto_increment,
  NAME varchar(32) not null default 'UNDEFINED CHAMPION',
  PERSONid mediumint unsigned not null,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  primary key (ID)
 );

drop table if exists TRAINING_PLAN;
create table if not exists TRAINING_PLAN
 (
  ID mediumint unsigned not null auto_increment,
  NAME varchar(128) not null,
  OBJECTIVE enum('Gain Muscle', 'Lose Weight', 'General Fitness', 'Toning', 'Other') not null default 'Other',
  PRIVATE enum('YES','NO') default 'NO' not null,
  PROFILEid mediumint unsigned not null,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  primary key (ID)
 );

drop table if exists TRAINING_PLAN_DEFINITION;
create table if not exists TRAINING_PLAN_DEFINITION
 (
  ID mediumint unsigned not null auto_increment,
  EXERCISE_WEEK tinyint unsigned default 1 null,
  EXERCISE_DAY enum('1','2','3','4','5','6','7') null,
  EXERCISE_ORDINALITY tinyint unsigned null,
  EXERCISEid mediumint unsigned not null,
  PLANid mediumint unsigned not null,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  primary key (ID)
 );

drop table if exists PROGRESS;
create table if not exists PROGRESS
 (
  ID mediumint unsigned  not null auto_increment,
  SET_ORDINALITY tinyint unsigned default 1 null,
  SET_REPS tinyint unsigned default 0 not null,
  SET_WEIGHT float default 0 not null,
  SET_COMMENT varchar(256) default '-' not null,
  SET_DATE datetime not null,
  BODY_WEIGHT float,
  DEFINITIONid mediumint unsigned not null,
  DATE_REGISTERED datetime(3) default current_timestamp(3) not null,
  primary key (ID)
 );
