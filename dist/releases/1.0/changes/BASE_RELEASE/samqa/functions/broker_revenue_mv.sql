-- liquibase formatted sql
-- changeset SAMQA:1754373926987 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\broker_revenue_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/broker_revenue_mv.sql:null:f0605d3be9131648e31364ff219a51aa92adc8bc:create

create or replace function samqa.broker_revenue_mv (
    p_mon_period number,
    p_num        number,
    p_result     number
) return clob sql_macro is
    l_sql   clob;
    l_sql2  clob;
    l_cond  varchar2(4000);
    l_cond2 varchar2(4000);
begin
    if p_mon_period = 1 then   -- year
        l_cond := q'{
		(TRUNC(PAY_APPROVED_DATE) BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_mv.p_num) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_mv.p_num+11 ) +30 AND TRUNC(start_date)    <= ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_mv.p_num+11 ) +30)
		  OR 
		(TRUNC(start_date)    BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_mv.p_num) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_mv.p_num+11 ) +30 AND TRUNC(PAY_APPROVED_DATE) <  ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue_mv.p_num))
		}';
        l_cond2 := q'{TRUNC(PAY_APPROVED_DATE)  BETWEEN ADD_MONTHS(TRUNC(SYSDATE,'YEAR'), -broker_revenue_mv.p_num) AND ADD_MONTHS(TRUNC(SYSDATE,'YEAR'), -broker_revenue_mv.p_num+11)+30}'
        ;
    elsif p_mon_period = 2 then -- period
        l_cond := q'{
		(TRUNC(PAY_APPROVED_DATE) BETWEEN add_months(trunc(sysdate), -broker_revenue_mv.p_num) AND trunc(sysdate) AND TRUNC(start_date)    <= trunc(sysdate))
		  OR 
		(TRUNC(start_date)    BETWEEN add_months(trunc(sysdate), -broker_revenue_mv.p_num) AND trunc(sysdate) AND TRUNC(PAY_APPROVED_DATE) <  add_months(trunc(sysdate), -broker_revenue_mv.p_num))
		}';
        l_cond2 := q'{TRUNC(PAY_APPROVED_DATE) BETWEEN add_months(trunc(sysdate), -broker_revenue_mv.p_num) AND trunc(sysdate)}';
    else
        l_cond := '1=1';
        l_cond2 := '1=1';
    end if;

    l_sql := 'select * from BROKER_ACCOUNT_NONHSA_REVENUE_MV where ' || l_cond;
    l_sql := l_sql
             || ' UNION ALL '
             || 'select * from BROKER_ACCOUNT_HSA_REVENUE_MV where '
             || l_cond2;
    l_sql2 := 'SELECT BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip,(SUM(SETUP)+SUM(SETUP_DISCOUNT)+SUM(SETUP_OPTIONAL))"SETUP",(SUM(MONTHLY)+SUM(MONTHLY_DISCOUNT))"MONTHLY",SUM(REVENUE_AMOUNT) "SUM_REVENUE" 
    FROM ('
              || l_sql
              || ')
	HAVING SUM(REVENUE_AMOUNT)>0 
	GROUP BY BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip
	ORDER BY SUM(REVENUE_AMOUNT) DESC';
    if p_result = 1 then
        return l_sql;
    elsif p_result = 2 then
        return l_sql2;
    end if;

end;
/

