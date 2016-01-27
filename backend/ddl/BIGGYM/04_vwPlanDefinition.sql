/*
Name       : vwPlanDefinition
Object Type: VIEW
Dependency : TRAINING_PLAN(TABLE), TRAINING_PLAN_DEFINITION(TABLE), EXERCISE(TABLE)
*/

use BIGGYM;

create or replace view vwPlanDefinition as
select 
    def.PLANid,
    def.ID DEFINITIONid,
    def.EXERCISEid,
    def.DATE_REGISTERED REGISTRATION_DEFINITION,
    round(datediff(curdate(), def.DATE_REGISTERED), 1) DEFINITION_AGE,
    def.PLAN_DAY,
    def.EXERCISE_ORDINALITY,
    exc.NAME EXERCISE_NAME,
    exc.BODY_PART
  from
    TRAINING_PLAN plan,
    TRAINING_PLAN_DEFINITION def,
    EXERCISE exc
 where
    plan.ID = def.PLANid
   and
    def.EXERCISEid = exc.ID
     ;
     
select * from vwPlanDefinition limit 10;
