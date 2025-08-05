-- liquibase formatted sql
-- changeset SAMQA:1754373926906 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\broker_rev_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/broker_rev_fn.sql:null:759e289d0f41666f3a3fe1028c4df8cddac5b179:create

create or replace function samqa.broker_rev_fn (
    p_mon_period        number,
    p_num               number,
    p_hasrev            number,
    p_result            number,
    p_filter_start_date varchar2,
    p_filter_end_date   varchar2
) -- 20240926 add , p_filter_start_date date, p_filter_end_date date
 return clob sql_macro is
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
		--20260926  add section
        l_cond := q'{
		(TRUNC(pay_approved_date) BETWEEN to_date(p_filter_start_date,'YYYY-MM-DD') AND to_date(p_filter_end_date,'YYYY-MM-DD') AND TRUNC(start_date)        <= to_date(p_filter_end_date,'YYYY-MM-DD'))
		  OR 
		(TRUNC(start_date)        BETWEEN to_date(p_filter_start_date,'YYYY-MM-DD') AND to_date(p_filter_end_date,'YYYY-MM-DD') AND TRUNC(pay_approved_date) <  to_date(p_filter_start_date,'YYYY-MM-DD'))
		}';
        l_cond2 := q'{TRUNC(pay_approved_date)  BETWEEN to_date(p_filter_start_date,'YYYY-MM-DD') AND to_date(p_filter_end_date,'YYYY-MM-DD')}'
        ;
    else
        l_cond := '1=1';
        l_cond2 := '1=1';
    end if;

    l_sql := 'select * from BROKER_ACCOUNT_NOHSA_REV_MV where ' || l_cond;
    l_sql := l_sql
             || ' UNION ALL '
             || 'select * from BROKER_ACCOUNT_HSA_REV_MV where '
             || l_cond2;
    l_sql2 := q'{SELECT broker,broker_id,salesrep_id,salesrep_name,city,state,zip,(sum(setup)+sum(setup_discount)+sum(setup_optional)) as setup, (sum(monthly)+sum(monthly_discount)) as monthly, sum(revenue_amount) as sum_revenue,}'
              || q'{COUNT(DISTINCT(ACCOUNT_TYPE)) account_type_count, REGEXP_REPLACE(listagg(ACCOUNT_TYPE,',' ON OVERFLOW TRUNCATE '...') WITHIN GROUP (ORDER BY ACCOUNT_TYPE)  ,'([^,]+)(,\1)*(,|$)', '\1\3') account_types	}'
              || 'FROM ('
              || l_sql
              || ')';
    if p_hasrev = 1 then
        l_sql2 := l_sql2 || ' HAVING SUM(revenue_amount)>0 ';
    else
        l_sql2 := l_sql2 || ' HAVING SUM(revenue_amount)=0 ';
    end if;

    l_sql2 := l_sql2 || ' GROUP BY BROKER,BROKER_ID,SALESREP_ID,SALESREP_NAME,city,state,zip  ORDER BY SUM(revenue_amount) DESC';
    if p_result = 1 then
        return l_sql;
    elsif p_result = 2 then
        return l_sql2;
    end if;

end;
/

