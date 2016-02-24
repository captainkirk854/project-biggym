use BIGGYM;

alter table PERSON 
 add unique index IDXU_PERSON_01 
 (
  FIRST_NAME asc, 
  LAST_NAME asc, 
  BIRTH_DATE asc
 );

alter table PROFILE
 add unique index IDXU_PROFILE_01
 (
  NAME asc,
  PERSONid asc
 );

alter table EXERCISE 
 add unique index IDXU_EXERCISE_01 
 (
  NAME asc, 
  BODY_PART asc
 );

alter table TRAINING_PLAN
 add unique index IDXU_TRAINING_PLAN_01 
 (
  NAME asc, 
  PROFILEid asc
 );

alter table TRAINING_PLAN_DEFINITION
 add unique index IDXU_TRAINING_PLAN_DEFINITION_01
 (
  PLANid asc, 
  EXERCISEid asc, 
  EXERCISE_WEEK asc,
  EXERCISE_DAY asc,
  EXERCISE_ORDINALITY asc
 );

alter table PROGRESS 
 add unique index IDXU_PROGRESS_01 
 (
  DEFINITIONid asc, 
  SET_ORDINALITY asc, 
  SET_REPS asc, 
  SET_WEIGHT asc, 
  SET_DATE asc 
 );
