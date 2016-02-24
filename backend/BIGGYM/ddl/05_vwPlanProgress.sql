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
     round(datediff(curdate(), prg.SET_DATE), 1) PROGRESS_AGE,
     prg.SET_REPS,
     prg.SET_WEIGHT,
     prg.SET_DATE,
     prg.SET_ORDINALITY
 from
     vwPlanDefinition vwPD,
     PROGRESS prg 
where
     vwPD.DEFINITIONid = prg.DEFINITIONid
    ;

select * from vwPlanProgress order by SET_DATE, SET_ORDINALITY limit 10;
