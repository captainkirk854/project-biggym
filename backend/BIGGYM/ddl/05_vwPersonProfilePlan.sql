/*
Name       : vwPersonProfilePlan
Object Type: VIEW
Dependency : vwPersonProfile(VIEW), TRAINING_PLAN(TABLE)
*/

use BIGGYM;

create or replace view vwPersonProfilePlan as
select  
    plan.ID PLANid,
    vwPP.*,
    plan.NAME PLAN_NAME,
    plan.private,
    plan.C_CREATE PLAN_REGISTRATION,
    round(datediff(curdate(), plan.C_LASTMOD), 1) PLAN_AGE
  from 
    vwPersonProfile vwPP,
    TRAINING_PLAN plan
 where 
    vwPP.PERSONPROFILEid = plan.PROFILEid
 ;
 
  select * from vwPersonProfilePlan limit 10;
