/*
Name       : vwPlanProgress
Object Type: VIEW
Dependency : vwPlanDefinition(VIEW), PROGRESS(TABLE)
*/

use BIGGYM;

create or replace view vwPlanProgress as
select
     prg.ID PROGRESSId,
     vwPD.*,
     prg.DATE_REGISTERED PROGRESS_REGISTRATION,
     round(datediff(curdate(), prg.DATE_PHYSICAL), 1) PROGRESS_AGE,
     prg.SET_REPS,
     prg.SET_WEIGHT,
     prg.DATE_PHYSICAL,
     prg.SET_ORDINALITY
 from
     vwPlanDefinition vwPD,
     PROGRESS prg 
where
     vwPD.DEFINITIONid = prg.DEFINITIONid
    ;

select * from vwPlanProgress order by DATE_PHYSICAL, SET_ORDINALITY limit 10;
