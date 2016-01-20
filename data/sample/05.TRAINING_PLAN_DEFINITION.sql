use BIGGYM;

-- TRAINING_PLAN_DEFINITION

insert into TRAINING_PLAN_DEFINITION 
(
 PLANid, 
 EXERCISEid
) 
values
( 
 (
   select ID from TRAINING_PLAN where NAME = 'Ultimate, Predator-beating training plan'
  and
   PROFILEid = 
    (
      select ID from PROFILE where NAME = 'Dutch Schaefer'
     and 
      PERSONid =
       (select ID from PERSON where FIRST_NAME = 'Arnold' and LAST_NAME = 'Schwarzenegger' and BIRTH_DATE = '1947-07-30' )
    )
 ), 
 (select ID from EXERCISE where BODY_PART = 'Chest' and NAME = 'Bench Press') 
);

insert into TRAINING_PLAN_DEFINITION 
(
 PLANid, 
 EXERCISEid
) 
values
( 
 (
   select ID from TRAINING_PLAN where NAME = 'Ultimate, Predator-beating training plan'
  and
   PROFILEid = 
    (
      select ID from PROFILE where NAME = 'Dutch Schaefer'
     and 
      PERSONid =
       (select ID from PERSON where FIRST_NAME = 'Arnold' and LAST_NAME = 'Schwarzenegger' and BIRTH_DATE = '1947-07-30' )
    )
 ),
 (select ID from EXERCISE where BODY_PART = 'Legs' and NAME = 'Squats')
);

insert into TRAINING_PLAN_DEFINITION
(
 PLANid,
 EXERCISEid
)
values
(
 (
   select ID from TRAINING_PLAN where NAME = 'Heavy Lifting - Maximum Contraction'
  and
   PROFILEid =
    (
      select ID from PROFILE where NAME = 'Muscular Mike'
     and
      PERSONid =
       (select ID from PERSON where FIRST_NAME = 'Mike' and LAST_NAME = 'Mentzer' and BIRTH_DATE = '1951-11-15' )
    )
 ),
 (select ID from EXERCISE where BODY_PART = 'All' and NAME = 'Deadlift')
);
