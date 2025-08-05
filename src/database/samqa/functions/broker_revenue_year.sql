create or replace function samqa.broker_revenue_year (
    p_month    number,
    p_salesrep number
) return clob sql_macro is
begin
    return q'{
SELECT BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip,(SUM(SETUP)+SUM(SETUP_DISCOUNT)+SUM(SETUP_OPTIONAL)) SETUP,(SUM(MONTHLY)+SUM(MONTHLY_DISCOUNT)) MONTHLY, SUM(REVENUE_AMOUNT) SUM_REVENUE
FROM 
(
SELECT
	a.*
FROM  
	broker_revenue_no_hsa a
WHERE
    (  	
	(TRUNC(A.PAY_APPROVED_DATE) BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month+11 ) +30 AND TRUNC(A.START_DATE)        <= ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month+11 ) +30)
	  OR 
	(TRUNC(A.START_DATE)    	BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month+11 ) +30 AND TRUNC(A.PAY_APPROVED_DATE) <  ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month))
	) AND ((p_SALESREP>0 AND salesrep_id <>0 ) OR (p_SALESREP=0 AND salesrep_id=0))
UNION ALL
SELECT 
    b.*
FROM	
	broker_revenue_hsa b
WHERE   
	TRUNC(b.PAY_APPROVED_DATE)  BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_year.p_month+11 ) +30
	AND ((p_SALESREP>0 AND salesrep_id <>0 ) OR (p_SALESREP=0 AND salesrep_id=0))
)
HAVING SUM(REVENUE_AMOUNT)>0 
GROUP BY BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip
ORDER BY SUM(REVENUE_AMOUNT) DESC
 }';
end;
/


-- sqlcl_snapshot {"hash":"d59387bf1368a85566416f192a69a40fcb8e19d3","type":"FUNCTION","name":"BROKER_REVENUE_YEAR","schemaName":"SAMQA","sxml":""}