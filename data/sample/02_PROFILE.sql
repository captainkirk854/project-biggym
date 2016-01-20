use BIGGYM;

-- PROFILE
insert into PROFILE
(
 NAME,
 PERSONid
)
values
(
 'Big Jim',
 (
  select ID 
   from PERSON 
  where 
        FIRST_NAME = 'JIM' 
    and 
        LAST_NAME = 'Nasium' 
    and 
       BIRTH_DATE = '3000-01-01 00:00:00'
 )
);

insert into PROFILE
(
 NAME,
 PERSONid
)
values
(
 'Lucky Luke',
 (
  select ID 
   from PERSON 
  where 
        FIRST_NAME = 'Luke' 
    and 
        LAST_NAME = 'Skywalker' 
    and 
       BIRTH_DATE = '1951-09-25'
 )
);

insert into PROFILE
(
 NAME,
 PERSONid
)
values
(
 'Captain Kirk',
 (
  select ID
   from PERSON
  where
        FIRST_NAME = 'William'
    and
        LAST_NAME = 'Shatner'
    and
       BIRTH_DATE = '1931-03-22'
 )
);

insert into PROFILE
(
 NAME,
 PERSONid
)
values
(
 'Muscular Mike',
 (
  select ID
   from PERSON
  where
        FIRST_NAME = 'Michael'
    and
        LAST_NAME = 'Ironside'
    and
       BIRTH_DATE = '1950-02-12'
 )
);

insert into PROFILE
(
 NAME,
 PERSONid
)
values
(
 'Muscular Mike',
 (
  select ID
   from PERSON
  where
        FIRST_NAME = 'Mike'
    and
        LAST_NAME = 'Mentzer'
    and
       BIRTH_DATE = '1951-11-15'
 )
);

insert into PROFILE
(
 NAME, 
 PERSONid
)
values
(
 'Numero Uno',
 (
  select ID
   from PERSON
  where
        FIRST_NAME = 'Arnold'
    and
        LAST_NAME = 'Schwarzenegger'
    and
       BIRTH_DATE = '1947-07-30'
 )
);

insert into PROFILE
(
 NAME, 
 PERSONid
)
values
(
 'Col. John Matrix',
 (
  select ID
   from PERSON
  where
        FIRST_NAME = 'Arnold'
    and
        LAST_NAME = 'Schwarzenegger'
    and
       BIRTH_DATE = '1947-07-30'
 )
);

insert into PROFILE
(
 NAME, 
 PERSONid
)
values
(
 'Dutch Schaefer',
 (
  select ID
   from PERSON
  where
        FIRST_NAME = 'Arnold'
    and
        LAST_NAME = 'Schwarzenegger'
    and
       BIRTH_DATE = '1947-07-30'
 )
);
