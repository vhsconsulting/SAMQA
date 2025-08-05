create or replace function samqa.broker_revenue_period (
    p_period   number,
    p_salesrep number
) return clob sql_macro is
begin
    return q'{
	SELECT BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip,(SUM(SETUP)+SUM(SETUP_DISCOUNT)+SUM(SETUP_OPTIONAL))"SETUP",(SUM(MONTHLY)+SUM(MONTHLY_DISCOUNT))"MONTHLY",SUM(REVENUE_AMOUNT) "SUM_REVENUE" 
    FROM 
	( 
	SELECT
		a.*
	FROM  
		broker_revenue_no_hsa a
	WHERE  	
		 ((TRUNC(A.PAY_APPROVED_DATE) BETWEEN add_months(trunc(sysdate), -p_PERIOD) AND trunc(sysdate) AND TRUNC(A.START_DATE)    <= trunc(sysdate))
		  OR 
		 (TRUNC(A.START_DATE)    BETWEEN add_months(trunc(sysdate), -p_PERIOD) AND trunc(sysdate) AND TRUNC(A.PAY_APPROVED_DATE) <  add_months(trunc(sysdate), -p_PERIOD))
		 ) AND 
		 ((p_SALESREP>0 AND salesrep_id <>0 ) OR (p_SALESREP=0 AND salesrep_id=0))
	UNION ALL
	SELECT 
		b.*
	FROM	
		broker_revenue_hsa b
	WHERE	
		TRUNC(PAY_APPROVED_DATE) BETWEEN add_months(trunc(sysdate), -p_PERIOD) AND trunc(sysdate) AND 
		((p_SALESREP>0 AND salesrep_id <>0 ) OR (p_SALESREP=0 AND salesrep_id=0))
	)
	HAVING SUM(REVENUE_AMOUNT)>0 
	GROUP BY BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip
	ORDER BY SUM(REVENUE_AMOUNT) DESC
 }';
end;
/


-- sqlcl_snapshot {"hash":"bef821d523de7bef4323bd2686b6a27ef038ab24","type":"FUNCTION","name":"BROKER_REVENUE_PERIOD","schemaName":"SAMQA","sxml":""}