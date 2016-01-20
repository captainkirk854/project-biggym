use BIGGYM;

-- 01
select  
      concat(per.FIRST_NAME, ' ', per.LAST_NAME, ' (aka ', prf.NAME, ')') PERSON,
      round((datediff(curdate(), per.BIRTH_DATE) / 365),0) AGE,
      prf.ID PROFILEid
  from 
      PERSON per, 
      PROFILE prf 
 where 
      prf.PERSONid = per.ID
 order by
      per.BIRTH_DATE asc
 ;


-- 02
select  
      concat(per.FIRST_NAME, ' ', per.LAST_NAME, ' (aka ', prf.NAME, ')') PERSON,
      round((datediff(curdate(), per.BIRTH_DATE) / 365),0) AGE,
      plan.NAME PLAN_NAME,
      plan.DATE_REGISTERED DATE_PLAN_WAS_REGISTERED,
      plan.ID PLANid
  from 
      PERSON per, 
      PROFILE prf,
      TRAINING_PLAN plan
 where 
      prf.PERSONid = per.ID
   and
      prf.ID = plan.PROFILEid
 order by
      per.BIRTH_DATE asc
 ;

-- 03
select
      concat(per.FIRST_NAME, ' ', per.LAST_NAME, ' (aka ', prf.NAME, ')') PERSON,
      round((datediff(curdate(), per.BIRTH_DATE) / 365),0) AGE,
      plan.NAME PLAN_NAME,
      plan.DATE_REGISTERED DATE_PLAN_WAS_REGISTERED,
      exc.BODY_PART,
      exc.NAME
  from
      PERSON per,
      PROFILE prf,
      TRAINING_PLAN plan,
      TRAINING_PLAN_DEFINITION def,
      EXERCISE exc
 where
      prf.PERSONid = per.ID
   and
      prf.ID = plan.PROFILEid
   and
      plan.ID = def.PLANid
   and
     def.EXERCISEid = exc.ID
 order by
      per.BIRTH_DATE asc,
      exc.BODY_PART asc
 ;

-- 04
select
      concat(per.FIRST_NAME, ' ', per.LAST_NAME, ' (aka ', prf.NAME, ')') PERSON,
      round((datediff(curdate(), per.BIRTH_DATE) / 365),0) AGE,
      plan.NAME PLAN_NAME,
      prg.DATE_REGISTERED TRAINING_DATE,
      exc.BODY_PART,
      exc.NAME,
      concat(prg.SET_01_WEIGHT, 'kg', ' x', prg.SET_01_REPS) SET01,
      concat(prg.SET_02_WEIGHT, 'kg', ' x', prg.SET_02_REPS) SET02,
      concat(prg.SET_03_WEIGHT, 'kg', ' x', prg.SET_03_REPS) SET03,
      (prg.SET_01_WEIGHT * prg.SET_01_REPS) +
      (prg.SET_02_WEIGHT * prg.SET_02_REPS) +
      (prg.SET_03_WEIGHT * prg.SET_03_REPS) TOTAL_KG 
  from
      PERSON per,
      PROFILE prf,
      TRAINING_PLAN plan,
      TRAINING_PLAN_DEFINITION def,
      EXERCISE exc,
      PROGRESS prg
 where
      prf.PERSONid = per.ID
   and
      prf.ID = plan.PROFILEid
   and
      plan.ID = def.PLANid
   and
     def.EXERCISEid = exc.ID
   and
     def.ID = prg.DEFINITIONid
 order by
      per.BIRTH_DATE asc,
      exc.BODY_PART asc,
      prg.DATE_REGISTERED asc
 ;

