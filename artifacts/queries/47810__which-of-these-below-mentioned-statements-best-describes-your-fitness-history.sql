SELECT answers,
       COUNT(DISTINCT userid) users
FROM(
select userid,
      listagg(DISTINCT answer,', ') WITHIN GROUP (ORDER BY answer) answers
       
from pk_curefitprod_cfdb.npsresponses 
where formid = 'post_pack_purchase_onboarding'  
-- Report end date keeps survey counts stable across future query runs.
and date(createddate) between DATE('2023-04-01') and {{end_date}}
and answer IS NOT NULL --and questiontext NOT IN ('What is your height?', 'Your age?', 'What is your date of birth?', 'What is your current weight (in kgs)?')
and questiontext IN ('Which of these below-mentioned statements best describes your fitness history.')
GROUP BY 1
ORDER BY 2 desc
)
GROUP BY 1
ORDER BY 2 desc