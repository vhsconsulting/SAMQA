create or replace function samqa.sales_activity_log_fn (
    p_activity_code in varchar2,
    p_from_date     in date,
    p_to_date       in date,
    p_sales_rep_id  in number
) return varchar2 is
    l_qry   varchar2(32767);
    l_count number := 0;
begin
    for x in (
        select
            to_char(period_date, 'MON') pmon,
            to_char(period_date, 'MM')  pmm
        from
            monthly_v
        order by
            to_char(period_date, 'MM')
    ) loop
        if l_qry is null then
            l_qry := '';
        else
            l_qry := l_qry || ' UNION ALL ';
        end if;

        l_qry := l_qry
                 || 'SELECT null,  '''
                 || x.pmon
                 || ''' PMON';
        for xx in (
            select
                b.user_id,
                a.salesrep_id,
                b.first_name
                || ' '
                || b.last_name name
            from
                salesrep a,
                employee b
            where
                    a.status = 'A'
                and a.emp_id = b.emp_id
                and a.role_type = 'SALESREP'
                and b.user_id = nvl(p_sales_rep_id, b.user_id)
        ) loop
            l_count := 0;

          --Loop through the states and add a sum(decode...) column with column alias
            for r1 in (
                select
                    user_id,
                    name
                from
                    (
                        select
                            b.user_id,
                            b.first_name
                            || ' '
                            || b.last_name                  name,
                            to_char(c.creation_date, 'MON') cmon
                        from
                            salesrep           a,
                            employee           b,
                            sales_activity_log c
                        where
                                a.salesrep_id = xx.salesrep_id
                            and a.status (+) = 'A'
                            and a.emp_id (+) = b.emp_id
                            and c.created_by (+) = b.user_id
                            and c.activity_code (+) = p_activity_code
                            and trunc(c.creation_date) between p_from_date and p_to_date
                            and a.role_type = 'SALESREP'
                    ) xx
                where
                    xx.cmon (+) = x.pmon
                group by
                    user_id,
                    name,
                    cmon
            ) loop
                l_qry := l_qry
                         || ',sum(decode(created_by,'''
                         || r1.user_id
                         || ''',number_of_activity,0)) "'
                         || r1.name
                         || '" ';

                l_count := l_count + 1;
            end loop;

            if l_count = 0 then
                l_qry := l_qry
                         || ',0 "'
                         || xx.name
                         || '" ';
            end if;

        end loop;
      --Trim off trailing comma
     -- l_qry := rtrim(l_qry, ',');
       --Append the rest of the query
        l_qry := l_qry
                 || ' FROM SALES_ACTIVITY_LOG WHERE ACTIVITY_CODE = '''
                 || p_activity_code
                 || ''' AND TRUNC(c.creation_date) = '
                 || x.pmon
                 || ' GROUP BY TO_CHAR(CREATION_DATE,''MON'')'
                 || chr(10);

        pc_log.log_error('sales_activity_log_fn',
                         'length ' || length(l_qry));
        pc_log.log_error('sales_activity_log_fn', 'query ' || l_qry);
    end loop;

    return l_qry;
end sales_activity_log_fn;
/


-- sqlcl_snapshot {"hash":"c26fd2b61e918a8b5476cc938bf59af2c9bcb9d9","type":"FUNCTION","name":"SALES_ACTIVITY_LOG_FN","schemaName":"SAMQA","sxml":""}