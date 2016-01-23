use BIGGYM;

select 
      vwPePrPl.*,
      vwPlPr.*
  from 
      vwPersonProfilePlan vwPePrPl,
      vwPlanProgress vwPlPr
 where
       vwPePrPl.PLANid = vwPlPr.PLANid
     ;
