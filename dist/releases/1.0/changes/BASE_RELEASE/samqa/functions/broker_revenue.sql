-- liquibase formatted sql
-- changeset SAMQA:1754373926969 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\broker_revenue.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/broker_revenue.sql:null:9e6759117fc2aa054dbb6151d051ee7201db7098:create

create or replace function samqa.broker_revenue (
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
		(TRUNC(i.approved_date) BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue.p_num) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue.p_num+11 ) +30 AND TRUNC(i.START_DATE)    <= ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue.p_num+11 ) +30)
		  OR 
		(TRUNC(i.START_DATE)    BETWEEN ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue.p_num) AND ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue.p_num+11 ) +30 AND TRUNC(i.approved_date) <  ADD_MONTHS (TRUNC (SYSDATE,'YEAR'), -broker_revenue.p_num))
		}';
        l_cond2 := q'{TRUNC(p.pay_date)  BETWEEN ADD_MONTHS(TRUNC(SYSDATE,'YEAR'), -broker_revenue.p_num) AND ADD_MONTHS(TRUNC(SYSDATE,'YEAR'), -broker_revenue.p_num+11)+30}'
        ;
    elsif p_mon_period = 2 then -- period
        l_cond := q'{
		(TRUNC(i.approved_date) BETWEEN add_months(trunc(sysdate), -broker_revenue.p_num) AND trunc(sysdate) AND TRUNC(i.START_DATE)    <= trunc(sysdate))
		  OR 
		(TRUNC(i.START_DATE)    BETWEEN add_months(trunc(sysdate), -broker_revenue.p_num) AND trunc(sysdate) AND TRUNC(i.approved_date) <  add_months(trunc(sysdate), -broker_revenue.p_num))
		}';
        l_cond2 := q'{TRUNC(p.pay_date) BETWEEN add_months(trunc(sysdate), -broker_revenue.p_num) AND trunc(sysdate)}';
    else
        l_cond := '1=1';
        l_cond2 := '1=1';
    end if;

    l_sql := q'{select q.ACC_ID,q.ACCOUNT_TYPE,q.BROKER_ID,nvl(q.SALESREP_ID, 0) salesrep_id,q.BROKER,q.MONTHLY_DISCOUNT,q.SETUP_DISCOUNT,q.SETUP,q.SETUP_OPTIONAL,q.MONTHLY,q.REVENUE_AMOUNT,q.PAY_APPROVED_DATE,q.START_DATE,q.CITY,q.STATE,q.ZIP,s.name AS SALESREP_NAME from (SELECT i.acc_id,
    a.account_type,
    a.broker_id, 
    case when i.salesrep_id is not null and i.salesrep_id != 0 then i.salesrep_id
        else case when a.salesrep_id is not null and a.salesrep_id != 0 then a.salesrep_id
            else bk.salesrep_id  end
            end salesrep_id,    
    replace(trim(pers.first_name|| ' '|| pers.last_name),'  ',' ') AS "BROKER",
    CASE
        WHEN a.account_type IN ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500', 'ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
             AND il.rate_code = 89
             AND EXISTS (
            SELECT
                *
            FROM
                ar_invoice_lines
            WHERE
                invoice_id = il.invoice_id AND rate_code IN ( 183, 184 )
        ) THEN
            il.total_line_amount
        ELSE
            0
    END                                         "MONTHLY_DISCOUNT",
    CASE
        WHEN a.account_type IN ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500', 'ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
             AND il.rate_code = 264
             OR ( il.rate_code IN ( 89, 266 )
                  AND EXISTS (
            SELECT
                *
            FROM
                ar_invoice_lines
            WHERE
                invoice_id = il.invoice_id AND rate_code IN ( 1, 100, 43, 44 )
        ) ) THEN
            il.total_line_amount
        ELSE
            0
    END                                         "SETUP_DISCOUNT",
    CASE
        WHEN a.account_type IN ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500','ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
             AND p.reason_code IN ( 1, 100, 43, 44 ) THEN
            il.total_line_amount
        ELSE
            0
    END                                         "SETUP",
    CASE
        WHEN a.account_type = 'COBRA'
             AND il.rate_code IN ( 54, 55, 86 )
             AND EXISTS (
            SELECT
                *
            FROM
                ar_invoice_lines
            WHERE
                    invoice_id = il.invoice_id
                AND rate_code IN ( 1, 100, 43, 44, 184 )
        ) THEN
            il.total_line_amount
        ELSE
            0
    END                                         "SETUP_OPTIONAL",
    (
        CASE
            WHEN p.reason_code = 184 THEN
                il.total_line_amount
            WHEN a.account_type IN ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500', 'ACA', 'FSA', 'HRA', 'RB' )
                 AND p.reason_code IN ( 2, 35, 31, 33, 67,34, 68, 36, 39, 38,37, 32, 40 )
                 AND ( greatest(trunc(a.reg_date), trunc(a.start_date)) >= add_months(trunc(i.start_date),- 12) ) THEN
                il.total_line_amount
            WHEN a.account_type = 'FMLA'
                 AND p.reason_code = 2
                 AND ( greatest(trunc(a.reg_date), trunc(a.start_date)) >= add_months(trunc(i.start_date),- 11) ) THEN
                il.total_line_amount
            ELSE
                0
        END
    )                                           "MONTHLY",
    CASE
        WHEN il.rate_code = 264
             OR ( il.rate_code IN ( 89, 266 )
                  AND EXISTS (
                SELECT
                    *
                FROM
                    ar_invoice_lines
                WHERE
                    invoice_id = il.invoice_id AND rate_code IN ( 1, 100, 43, 44, 184 )
            ) ) THEN
                il.total_line_amount
        ELSE
            0
    END
    +
    CASE
        WHEN a.account_type = 'COBRA'
             AND il.rate_code IN ( 54, 55, 86 )
             AND EXISTS (
                SELECT
                    *
                FROM
                    ar_invoice_lines
                WHERE
                    invoice_id = il.invoice_id AND rate_code IN ( 1, 100, 43, 44, 184 )
            ) THEN
                il.total_line_amount
        ELSE
            0
    END
    +
    CASE
        WHEN p.reason_code IN ( 1, 100, 43, 44 ) THEN
                il.total_line_amount
        ELSE
            0
    END
    + (
        CASE
            WHEN p.reason_code = 184 THEN
                il.total_line_amount
            WHEN a.account_type IN ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500','ACA', 'FSA', 'HRA', 'RB' )
                 AND p.reason_code IN ( 2, 35, 31, 33, 67, 34, 68, 36, 39, 38,37, 32, 40 )
                 AND ( greatest(trunc(a.reg_date),
                                trunc(a.start_date)) >= add_months(trunc(i.start_date),
                                                                   - 12) ) THEN
                il.total_line_amount
            WHEN a.account_type = 'FMLA'
                 AND p.reason_code = 2
                 AND ( greatest(trunc(a.reg_date),
                                trunc(a.start_date)) >= add_months(trunc(i.start_date),
                                                                   - 11) ) THEN
                il.total_line_amount
            ELSE
                0
        END
    )                                           AS "REVENUE_AMOUNT",
    i.approved_date      AS "PAY_APPROVED_DATE",
    i.start_date
    ,pers.city, pers.state, pers.zip
FROM
    ar_invoice       i,
    ar_invoice_lines il,
    pay_reason       p,
    account          a
   ,person           pers
   ,broker           bk
WHERE
        i.invoice_id = il.invoice_id
    AND i.acc_id = a.acc_id
    AND a.account_type IN ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500','FSA', 'HRA', 'ACA', 'RB', 'FMLA' )
    AND i.invoice_reason = 'FEE'
    AND ( i.status IN ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' ) AND il.status IN ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
    AND il.rate_code = to_char(p.reason_code)
	AND a.broker_id = pers.pers_id (+)
    AND a.broker_id = bk.broker_id
    AND
     (
	}'
             || l_cond
             || q'{
	)
    ) q, salesrep s
    where q.salesrep_id = s.salesrep_id(+) and  (monthly_discount+setup_discount+setup+setup_optional+monthly+revenue_amount > 0 )
   }';
    l_sql := l_sql
             || ' UNION ALL '
             || q'{
    SELECT q.ACC_ID,q.ACCOUNT_TYPE,q.BROKER_ID,nvl(q.SALESREP_ID, 0) salesrep_id,q.BROKER,q.MONTHLY_DISCOUNT,q.SETUP_DISCOUNT,q.SETUP,q.SETUP_OPTIONAL,q.MONTHLY,q.REVENUE_AMOUNT,q.PAY_APPROVED_DATE,q.START_DATE,q.CITY,q.STATE,q.ZIP,s.name AS SALESREP_NAME from (SELECT a.acc_id, 
    a.account_type,
    a.broker_id,
     case when a.salesrep_id is not null and a.salesrep_id != 0 then a.salesrep_id
            else bk.salesrep_id  end
             salesrep_id,    
    replace(trim(broker.first_name|| ' '|| broker.last_name),'  ',' ') AS "BROKER",
    0                                            AS "MONTHLY_DISCOUNT",
    0                                            AS "SETUP_DISCOUNT",
    0                                            AS "SETUP_OPTIONAL",
    CASE
        WHEN p.reason_code = 100 THEN
            p.amount
        ELSE
            0
    END                                         "SETUP",
    CASE
        WHEN p.reason_code = 2 THEN
            p.amount
        ELSE
            0
    END                                         "MONTHLY",
    CASE
        WHEN p.reason_code = 100 THEN
                p.amount
        ELSE
            0
    END
    + (
        CASE
            WHEN p.reason_code = 2 THEN
                p.amount
            ELSE
                0
        END
    )                    AS "REVENUE_AMOUNT",
    p.pay_date           AS "PAY_APPROVED_DATE",
    er.start_date
	,broker.city,broker.state,broker.zip
    FROM
        person  pers,
        account a,
        payment p,
        account er
       ,person broker
       ,broker bk
    WHERE
        a.account_type = 'HSA'    
    AND a.pers_id = pers.pers_id
    AND p.acc_id = a.acc_id
    AND pers.entrp_id = er.entrp_id
    AND pers.entrp_id IS NOT NULL 
    AND p.reason_code IN ( 2, 100 )       
    AND months_between(pay_date, er.start_date) <= 12
    AND a.broker_id = broker.pers_id(+)	
    AND a.broker_id = bk.broker_id
     (
	}'
             || l_cond2
             || q'{
	)
    ) q, salesrep s
    where q.salesrep_id = s.salesrep_id(+) and  (monthly_discount+setup_discount+setup+setup_optional+monthly+revenue_amount > 0 )
   }';
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

