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
     round(datediff(curdate(), prg.DATE_REGISTERED), 1) PROGRESS_AGE,
     prg.SET_01_REPS,
     prg.SET_01_WEIGHT,
     prg.SET_02_REPS,
     prg.SET_02_WEIGHT,
     prg.SET_03_REPS,
     prg.SET_03_WEIGHT,
     prg.SET_04_REPS,
     prg.SET_04_WEIGHT,
     prg.SET_05_REPS,
     prg.SET_05_WEIGHT,
     prg.SET_06_REPS,
     prg.SET_06_WEIGHT
 from
     vwPlanDefinition vwPD,
     PROGRESS prg
where
     vwPD.DEFINITIONid = prg.DEFINITIONid
    ;

select * from vwPlanProgress limit 10;
