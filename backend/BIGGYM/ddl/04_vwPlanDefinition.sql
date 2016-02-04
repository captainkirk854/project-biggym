/*
Name       : vwPlanDefinition
Object Type: VIEW
Dependency : TRAINING_PLAN(TABLE), TRAINING_PLAN_DEFINITION(TABLE), EXERCISE(TABLE)
*/

use BIGGYM;

create or replace view vwPlanDefinition as
select 
    def.ID DEFINITIONid,
    def.PLANid,
    def.EXERCISEid,
    def.DATE_REGISTERED DEFINITION_REGISTRATION,
    round(datediff(curdate(), def.DATE_REGISTERED), 1) DEFINITION_AGE,
    def.EXERCISE_WEEK,
    def.EXERCISE_DAY,
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
