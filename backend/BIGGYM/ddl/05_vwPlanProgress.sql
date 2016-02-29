/*
Name       : vwPlanProgress
Object Type: VIEW
Dependency : vwPlanDefinition(VIEW), PROGRESS(TABLE)
*/

use BIGGYM;

create or replace view vwPlanProgress as
select
     vwPS.*,
     prg.ID PROGRESSId,
     vwPD.*,
     prg.DATE_REGISTERED,
     prg.SET_DATE,
     round(datediff(curdate(), prg.SET_DATE), 1) SET_AGE,
     prg.SET_REPS,
     prg.SET_WEIGHT,
     prg.SET_ORDINALITY,
     prg.set_comment COMMENTS,
     prg.body_weight BODY_WEIGHT
 from
     vwPlanDefinition vwPD,
     vwPersonProfile vwPS,
     PROGRESS prg 
where
     vwPS.PERSONPROFILEid = vwPD.PLANPROFILEid
  and
     vwPD.DEFINITIONid = prg.DEFINITIONid
    ;

select * from vwPlanProgress order by SET_DATE, EXERCISE_ORDINALITY, EXERCISE_NAME, BODY_PART, EXERCISE_WEEK, EXERCISE_DAY , SET_ORDINALITY limit 100;
