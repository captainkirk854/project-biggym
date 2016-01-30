/*
Name       : vwPersonProfile
Object Type: VIEW
Dependency : PERSON(TABLE), PROFILE(TABLE)
*/

use BIGGYM;

create or replace view vwPersonProfile as
select
      per.ID PERSONid,
      prf.ID PROFILEid,
      per.FIRST_NAME, 
      per.LAST_NAME,
      per.BIRTH_DATE DOB,
      round((datediff(curdate(), per.BIRTH_DATE) / 365), 1) AGE,
      prf.NAME PROFILE_NAME,
      prf.DATE_REGISTERED PROFILE_REGISTRATION,
      round(datediff(curdate(), prf.DATE_REGISTERED), 1) PROFILE_AGE
  from 
      PERSON per, 
      PROFILE prf 
 where 
      prf.PERSONid = per.ID
     ;
 
 
 select * from vwPersonProfile limit 10;
