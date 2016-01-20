use BIGGYM;

-- TRAINING_PLAN

insert into TRAINING_PLAN 
(
 NAME, 
 PROFILEid
) 
values 
(
 'My winter training for big, big gains',
 (
  select ID from PROFILE 
   where NAME = 'Numero Uno' 
     and PERSONid = 
      (select ID from PERSON where FIRST_NAME = 'Arnold' and LAST_NAME = 'Schwarzenegger' and BIRTH_DATE = '1947-07-30')
 ) 
);

insert into TRAINING_PLAN 
(
 NAME, 
 PROFILEid
) 
values 
(
 'Ultimate, Predator-beating training plan' ,
 (
  select ID from PROFILE 
   where NAME = 'Dutch Schaefer'
     and PERSONid = 
      (select ID from PERSON where FIRST_NAME = 'Arnold' and LAST_NAME = 'Schwarzenegger' and BIRTH_DATE = '1947-07-30')
 )
);

insert into TRAINING_PLAN 
(
 NAME, 
 PROFILEid
) 
values 
(
 'Big Jims Big Gym',
 (
  select ID from PROFILE 
   where NAME = 'Big Jim'
     and PERSONid = 
      (select ID from PERSON where FIRST_NAME = 'Jim' and LAST_NAME = 'Nasium' and BIRTH_DATE = '3000-01-01')
 )
);

insert into TRAINING_PLAN 
(
 NAME, 
 PROFILEid
) 
values 
(
 'My winter training for big, big gains',
 (
  select ID from PROFILE 
   where NAME = 'Big Jim'
     and PERSONid = 
      (select ID from PERSON where FIRST_NAME = 'Jim' and LAST_NAME = 'Nasium' and BIRTH_DATE = '3000-01-01')
 )
);

insert into TRAINING_PLAN 
(
 NAME, 
 PROFILEid
) 
values 
(
 'High Rep Piggy Backs as instructed by Yoda on Dagobah.',
 (
  select ID from PROFILE 
   where NAME = 'Lucky Luke'
     and PERSONid = 
      (select ID from PERSON where FIRST_NAME = 'Luke' and LAST_NAME = 'Skywalker' and BIRTH_DATE = '1951-09-25')
 )
);

insert into TRAINING_PLAN 
(
 NAME, 
 PROFILEid
) 
values 
(
 'Heavy Lifting - Maximum Contraction',
 (
  select ID from PROFILE 
   where NAME = 'Muscular Mike'
     and PERSONid = 
      (select ID from PERSON where FIRST_NAME = 'Mike' and LAST_NAME = 'Mentzer' and BIRTH_DATE = '1951-11-15')
 )
);
