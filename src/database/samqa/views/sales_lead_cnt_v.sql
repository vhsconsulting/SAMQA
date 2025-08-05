
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SAMQA"."SALES_LEAD_CNT_V" ("SALES", "PRODUCT", "GENERATED") AS 
  SELECT
S.Name AS "SALES",a."product_c" as "PRODUCT",count("id")AS "GENERATED" 
from "leads"@sugarprod b,"leads_cstm"@sugarprod a ,salesrep S where a."id_c" = b."id" 
and a."sales_director_c"=to_char(s.salesrep_id)
and a."product_c" in ('COBRA',
'POP',
'FORM_5500',
'ERISA_WRAP',
'EVERGREEN_ERISA_WRAP',
'FSA',
'HSA',
'HRA',
'NDT',
'CMP',
'FMLA') 
and trunc(b."date_entered")  between TRUNC(TRUNC(SYSDATE,'YYYY'),'YYYY') AND TRUNC(SYSDATE)
and b."status" is NOT NULL
and b."deleted"=0
and s.status='A'
and b."status"='New'
group by a."product_c"@sugarprod,s.name
;


-- sqlcl_snapshot {"hash":"e952958f1c0730865c9600b3b472dc9b7048d808","type":"VIEW","name":"SALES_LEAD_CNT_V","schemaName":"SAMQA","sxml":""}