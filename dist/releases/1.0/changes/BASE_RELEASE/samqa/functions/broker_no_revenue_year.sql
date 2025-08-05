-- liquibase formatted sql
-- changeset SAMQA:1754373926864 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\broker_no_revenue_year.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/broker_no_revenue_year.sql:null:74dff024717692f8a75b286f0274c8b638fbf057:create

create or replace function samqa.broker_no_revenue_year (
    p_month number
) return clob sql_macro is
begin
    return q'{
with ab as
 (select a.acc_id, a.broker_id, replace(trim(broker.first_name|| ' '|| broker.last_name),'  ',' ') AS "BROKER", a.account_type, b.salesrep_id, s.name AS "SALESREP_NAME", broker.city, broker.state, broker.zip
  from account a, broker b, person broker, salesrep s
  where b.broker_id = a.broker_id 
  and a.broker_id = broker.pers_id (+)
  and b.salesrep_id = s.salesrep_id(+)
  -- and a.account_type IN ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500','FSA', 'HRA', 'ACA', 'RB', 'FMLA' )
  )
select distinct broker_id, broker, salesrep_id, SALESREP_NAME, city, state,zip
from ab 
where broker_id not in (
	SELECT distinct BROKER_ID FROM 
	(
		SELECT
			a.*
		FROM  
			broker_revenue_no_hsa a
		WHERE  	
			(TRUNC(A.PAY_APPROVED_DATE) BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH+11 ) +30 AND TRUNC(A.START_DATE)    <= ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH+11 ) +30)
			  OR 
			(TRUNC(A.START_DATE)    BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH+11 ) +30 AND TRUNC(A.PAY_APPROVED_DATE) <  ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH))
		UNION ALL
		SELECT 
			b.*
		FROM	
			broker_revenue_hsa b
		WHERE   
			TRUNC(b.PAY_APPROVED_DATE) BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_MONTH+11 ) +30
	)
	HAVING SUM(REVENUE_AMOUNT)>0 
	GROUP BY BROKER,BROKER_ID 
)
}';
end;
/

