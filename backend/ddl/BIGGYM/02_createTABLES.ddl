use BIGGYM;

drop table if exists PERSON;
create table if not exists PERSON
 (
  ID smallint  not null auto_increment,
  DATE_REGISTERED timestamp default current_timestamp not null,
  FIRST_NAME varchar(32) not null,
  LAST_NAME varchar(32) not null,
  BIRTH_DATE date not null,
  primary key (ID)
 );


drop table if exists PROFILE;
create table if not exists PROFILE
 (
  ID smallint  not null auto_increment,
  DATE_REGISTERED timestamp default current_timestamp not null,
  NAME varchar(32) not null DEFAULT 'UNKNOWN CHAMPION',
  PERSONid smallint not null,
  primary key (ID)
 );

drop table if exists EXERCISE;
create table if not exists EXERCISE
 (
  ID smallint not null auto_increment,
  DATE_REGISTERED timestamp default current_timestamp not null,
  NAME varchar(128) not null,
  BODY_PART varchar(128) not null,
  primary key (ID)
 );

drop table if exists TRAINING_PLAN;
create table if not exists TRAINING_PLAN
 (
  ID smallint not null auto_increment,
  DATE_REGISTERED timestamp default current_timestamp not null,
  NAME varchar(128) not null,
  VISIBILITY ENUM('YES','NO') default 'YES' not null,
  PROFILEid smallint not null,
  primary key (ID)
 );

drop table if exists TRAINING_PLAN_DEFINITION;
create table if not exists TRAINING_PLAN_DEFINITION
 (
  ID smallint not null auto_increment,
  DATE_REGISTERED timestamp default current_timestamp not null,
  PLANid smallint not null,
  EXERCISEid smallint not null,
  primary key (ID)
 );

drop table if exists PROGRESS;
create table if not exists PROGRESS
 (
  ID int not null auto_increment,
  DATE_REGISTERED timestamp default current_timestamp not null,
  DEFINITIONid smallint not null,
  SET_01_REPS smallint default 0 not null ,
  SET_01_WEIGHT FLOAT default 0 not null,
  SET_02_REPS smallint default 0 not null,
  SET_02_WEIGHT FLOAT default 0 not null,
  SET_03_REPS smallint default 0 not null,
  SET_03_WEIGHT FLOAT default 0 not null,
  SET_04_REPS smallint default 0 not null,
  SET_04_WEIGHT FLOAT default 0 not null,
  SET_05_REPS smallint default 0 not null,
  SET_05_WEIGHT FLOAT default 0 not null,
  SET_06_REPS smallint default 0 not null,
  SET_06_WEIGHT FLOAT default 0 not null,
  primary key (ID)
 );
