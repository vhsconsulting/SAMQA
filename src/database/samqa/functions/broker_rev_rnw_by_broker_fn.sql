create or replace function samqa.broker_rev_rnw_by_broker_fn (
    p_broker_id         number,
    p_mon_period        number,
    p_num               number,
    p_result            number,
    p_filter_start_date varchar2,
    p_filter_end_date   varchar2
) return clob sql_macro is
    l_sql   clob;
    l_sql2  clob;
    l_cond  varchar2(4000);
    l_cond2 varchar2(4000);
begin
    if p_mon_period = 1 then   -- year
        l_cond := q'{
		(TRUNC(pay_approved_date) BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_num) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_num+11 ) +30 AND TRUNC(start_date)        <= ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_num+11 ) +30)
		  OR 
		(TRUNC(start_date)        BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_num) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_num+11 ) +30 AND TRUNC(pay_approved_date) <  ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -p_num))
		}';
        l_cond2 := q'{TRUNC(pay_approved_date)  BETWEEN ADD_MONTHS(TRUNC(SYSDATE,'YEAR'), -p_num) AND ADD_MONTHS(TRUNC(SYSDATE,'YEAR'), -p_num+11)+30}'
        ;
    elsif p_mon_period = 2 then -- period
        l_cond := q'{
		(TRUNC(pay_approved_date) BETWEEN add_months(trunc(sysdate), -p_num) AND trunc(sysdate) AND TRUNC(start_date)    	 <= trunc(sysdate))
		  OR 
		(TRUNC(start_date)    	  BETWEEN add_months(trunc(sysdate), -p_num) AND trunc(sysdate) AND TRUNC(pay_approved_date) <  add_months(trunc(sysdate), -p_num))
		}';
        l_cond2 := q'{TRUNC(pay_approved_date) BETWEEN add_months(trunc(sysdate), -p_num) AND trunc(sysdate)}';
    elsif p_mon_period = 3 then -- section 
        l_cond := q'{
		(TRUNC(pay_approved_date) BETWEEN to_date(p_filter_start_date,'YYYY-MM-DD') AND to_date(p_filter_end_date,'YYYY-MM-DD') AND TRUNC(start_date)        <= to_date(p_filter_end_date,'YYYY-MM-DD'))
		  OR 
		(TRUNC(start_date)        BETWEEN to_date(p_filter_start_date,'YYYY-MM-DD') AND to_date(p_filter_end_date,'YYYY-MM-DD') AND TRUNC(pay_approved_date) < to_date(p_filter_start_date,'YYYY-MM-DD'))
		}';
        l_cond2 := q'{TRUNC(pay_approved_date)  BETWEEN to_date(p_filter_start_date,'YYYY-MM-DD') AND to_date(p_filter_end_date,'YYYY-MM-DD')}'
        ;
    else
        l_cond := '1=1';
        l_cond2 := '1=1';
    end if;

    l_sql := 'select * from BROKER_ACCOUNT_NOHSA_RNW_REV_MV where broker_id = '
             || p_broker_id
             || ' and ('
             || l_cond
             || ')';
    l_sql := l_sql
             || ' UNION ALL '
             || 'select * from BROKER_ACCOUNT_HSA_RNW_REV_MV where broker_id = '
             || p_broker_id
             || ' and ('
             || l_cond2
             || ')';

    l_sql2 := q'{SELECT broker,broker_id,salesrep_id,salesrep_name,city,state,zip, SUM(revenue_amount) as sum_revenue,}'
              || q'{COUNT(DISTINCT(ACCOUNT_TYPE)) account_type_count, REGEXP_REPLACE(listagg(ACCOUNT_TYPE,',' ON OVERFLOW TRUNCATE '...') WITHIN GROUP (ORDER BY ACCOUNT_TYPE)  ,'([^,]+)(,\1)*(,|$)', '\1\3') account_types	}'
              || 'FROM ('
              || l_sql
              || ')';
   
    --IF p_hasrev = 1 THEN
    l_sql2 := l_sql2 || ' HAVING SUM(revenue_amount)>0 ';
	--ELSE
	--   l_sql2:= l_sql2 ||' HAVING SUM(revenue_amount)=0 ';
	--END IF;

    l_sql2 := l_sql2 || ' GROUP BY BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip ORDER BY SUM(revenue_amount) DESC';
    if p_result = 1 then
        return l_sql;
    elsif p_result = 2 then
        return l_sql2;
    end if;

end;
/


-- sqlcl_snapshot {"hash":"eb96e789e0a8e147890fd6f065107eb92f29c82a","type":"FUNCTION","name":"BROKER_REV_RNW_BY_BROKER_FN","schemaName":"SAMQA","sxml":""}