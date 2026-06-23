select 
min(createddate_date) 
from pk_prod_enterprise_prod.Employeeregistrations 
where createddate_date is not null -- avoiding partion date
and cfuserid is not null -- curefit cuserid gets assigned only after membership
