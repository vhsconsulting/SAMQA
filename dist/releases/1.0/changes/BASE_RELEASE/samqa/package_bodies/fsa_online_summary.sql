-- liquibase formatted sql
-- changeset SAMQA:1754373950128 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\fsa_online_summary.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/fsa_online_summary.sql:null:e3122accbcac2683f5ab8fb94a4957883bd590b3:create

create or replace package body samqa.fsa_online_summary as

    function get_fsa_summary_sql (
        p_acc_id      in number,
        p_report_type in varchar2
    ) return varchar2 is

        l_query       varchar2(32000);
        l_count       number := 0;
        l_field_sel   varchar2(3200);
        l_exception exception;
        l_heading_sel varchar2(3200);
    begin
        execute immediate 'alter SESSION set nls_date_format=''DD-MON-YY''';
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) <= trunc(sysdate)
                and trunc(plan_end_date) >= trunc(sysdate)
        ) loop
            l_count := x.cnt;
        end loop;

        for x in (
            select
                count(*)
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) <= trunc(sysdate)
                and trunc(plan_end_date) >= trunc(sysdate)
            group by
                plan_type
            having
                count(*) > 1
        ) loop
            raise l_exception;
        end loop;

        if l_count > 0 then
            l_query := 'SELECT  TO_CHAR(a.check_date,''MON'') check_date
                        , TO_CHAR(a.check_date,''MM'') check_mm
                        , b.acc_id
                        , b.acc_num
                        , a.plan_type
                        , sum(a.check_amount) check_amount
                  FROM employer_deposits a
                     , account b
                 WHERE a.entrp_id = b.entrp_id
                  AND a.reason_code = 11
                  AND  b.account_type = ''FSA'' ';
            if p_acc_id is not null then
                l_query := l_query || ' AND B.ACC_ID = :acc_id '; --|| p_acc_id;

            end if;
            if p_report_type = 'SUMMARY' then
                l_query := l_query || ' AND TRUNC(CHECK_DATE) >= TRUNC(SYSDATE,''YYYY'') ';
            end if;
            l_query := l_query || ' GROUP BY TO_CHAR(a.check_date,''MON''), TO_CHAR(a.check_date,''MM''), b.acc_id, b.acc_num, a.plan_type '
            ;
            l_query := l_query || ' ORDER BY TO_CHAR(a.check_date,''MM'')) ';
            l_query := l_query || ' PIVOT ( sum(check_amount) AS AMT FOR plan_type IN ( ';
            l_count := 0;
            for x in (
                select
                    ben_plan_id,
                    plan_type
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and trunc(plan_start_date) <= trunc(sysdate)
                    and status <> 'R'
                    and trunc(plan_end_date) >= trunc(sysdate)
                order by
                    ben_plan_id
            ) loop
                l_count := l_count + 1;
                if l_count = 1 then
                    l_query := l_query
                               || ''''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := 'SUM(NVL( '
                                   || x.plan_type
                                   || '_AMT, 0)) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := x.plan_type;
                else
                    l_query := l_query
                               || ','''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := l_field_sel
                                   || ','
                                   || 'SUM(NVL( '
                                   || x.plan_type
                                   || '_AMT, 0)) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := l_heading_sel
                                     || ','
                                     || x.plan_type;
                end if;

            end loop;

            l_query := l_query || '  )';
            l_query := 'SELECT CHECK_DATE,ACC_ID,ACC_NUM,  '
                       || l_field_sel
                       || ' FROM ( '
                       || l_query
                       || ') GROUP BY CHECK_DATE,ACC_ID,ACC_NUM  ,CHECK_MM '
                       || 'ORDER BY CHECK_MM ';

            dbms_output.put_line('query ' || l_query);
        else
            l_query := null;
        end if;

        if l_count = 0 then
            return null;
        else
            return l_query;
        end if;
    exception
        when l_exception then
            return null;
    end;

    function get_fsa_detail_sql (
        p_acc_id          in number,
        p_plan_start_date in varchar2,
        p_plan_end_date   in varchar2,
        p_start_date      in varchar2,
        p_end_date        in varchar2,
        p_report_type     in varchar2
    ) return varchar2 is

        l_query       varchar2(32000);
        l_count       number := 0;
        l_field_sel   varchar2(3200);
        l_exception exception;
        l_heading_sel varchar2(3200);
    begin
        execute immediate 'alter SESSION set nls_date_format=''DD-MON-YY''';
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) = p_plan_start_date --TO_DATE(P_START_DATE,'MM/DD/YYYY')
                and trunc(plan_end_date) = p_plan_end_date
        )--TO_DATE(P_END_DATE,'MM/DD/YYYY'))
         loop
            l_count := x.cnt;
        end loop;

        for x in (
            select
                count(*)
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) = p_plan_start_date --TO_DATE(P_START_DATE,'MM/DD/YYYY')
                and trunc(plan_end_date) = p_plan_end_date --TO_DATE(P_END_DATE,'MM/DD/YYYY')
            group by
                plan_type
            having
                count(*) > 1
        ) loop
            raise l_exception;
        end loop;

        if l_count > 0 then
            l_query := 'SELECT   TO_CHAR(a.check_date,''MM/DD/YYYY'') check_date
                        , b.acc_id
                        , b.acc_num
                        , a.plan_type
                        , sum(a.check_amount) check_amount
                  FROM employer_deposits a
                     , account b
                 WHERE a.entrp_id = b.entrp_id
                  AND a.reason_code = 11
                  AND  b.account_type = :Product_Type';  -- ''FSA'' Replaced by :Product_Type by Swamy for Ticket#7967
            if p_acc_id is not null then
                l_query := l_query || ' AND B.ACC_ID = :acc_id '; --|| p_acc_id;

            end if;
            l_query := l_query || ' AND TRUNC(a.check_date) >= :start_date  ';
            l_query := l_query || ' AND TRUNC(a.check_date) <= :end_date  ';
            l_query := l_query || ' GROUP BY TO_CHAR(a.check_date,''MM/DD/YYYY''), b.acc_id, b.acc_num, a.plan_type ';
            l_query := l_query || ' ORDER BY a.check_date)  ';
            l_query := l_query || ' PIVOT ( sum(check_amount) AS AMT FOR plan_type IN ( ';
            l_count := 0;
            for x in (
                select
                    ben_plan_id,
                    plan_type
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and status <> 'R'
                    and trunc(plan_start_date) = p_plan_start_date
           --  AND STATUS = 'A'
                    and trunc(plan_end_date) = p_plan_end_date
                order by
                    ben_plan_id
            ) loop
                l_count := l_count + 1;
                if l_count = 1 then
                    l_query := l_query
                               || ''''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := 'NVL( '
                                   || x.plan_type
                                   || '_AMT, 0) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := x.plan_type;
                else
                    l_query := l_query
                               || ','''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := l_field_sel
                                   || ','
                                   || 'NVL( '
                                   || x.plan_type
                                   || '_AMT, 0) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := l_heading_sel
                                     || ','
                                     || x.plan_type;
                end if;

            end loop;

            l_query := l_query || '  )';
            l_query := 'SELECT CHECK_DATE,ACC_ID,ACC_NUM,  '
                       || l_field_sel
                       || ' FROM ( '
                       || l_query
                       || ') ORDER BY CHECK_DATE DESC ';
            dbms_output.put_line('query ' || l_query);
            pc_log.log_error('FSA_DETAIL_SQL', 'l_query ' || l_query);
        else
            l_query := null;
        end if;

        if l_count = 0 then
            return null;
        else
            return l_query;
        end if;
    exception
        when l_exception then
            pc_log.log_error('FSA_DETAIL_SQL', 'sqlerrm ' || sqlerrm);
            return null;
    end;

    function get_fsa_ee_summary_sql (
        p_acc_id      in number,
        p_report_type in varchar2
    ) return varchar2 is

        l_query       varchar2(32000);
        l_count       number := 0;
        l_field_sel   varchar2(3200);
        l_exception exception;
        l_heading_sel varchar2(3200);
    begin
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) <= trunc(sysdate)
                and trunc(plan_end_date) >= trunc(sysdate)
        ) loop
            l_count := x.cnt;
        end loop;

        for x in (
            select
                count(*)
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) <= trunc(sysdate)
                and trunc(plan_end_date) >= trunc(sysdate)
            group by
                plan_type
            having
                count(*) > 1
        ) loop
            raise l_exception;
        end loop;

        if l_count > 0 then
            l_query := 'SELECT  TO_CHAR(a.fee_date,''MON'') check_date
                        , TO_CHAR(a.fee_date,''MM'') check_mm
                        , b.acc_id
                        , b.acc_num
                        , a.plan_type
                        , sum(NVL(a.AMOUNT,0)+NVL(a.AMOUNT_ADD,0)) check_amount
                  FROM income a
                     , account b
                 WHERE a.acc_id = b.acc_id
                  AND a.fee_code = 11
                  AND  b.account_type = ''FSA'' ';
            if p_acc_id is not null then
                l_query := l_query || ' AND B.ACC_ID = :acc_id '; --|| p_acc_id;

            end if;
            if p_report_type = 'SUMMARY' then
                l_query := l_query || ' AND TRUNC(a.fee_date) >= TRUNC(SYSDATE,''YYYY'') ';
            end if;
            l_query := l_query || ' GROUP BY TO_CHAR(a.fee_date,''MON''), TO_CHAR(a.fee_date,''MM''), b.acc_id, b.acc_num, a.plan_type '
            ;
            l_query := l_query || ' ORDER BY TO_CHAR(a.fee_date,''MM'')) ';
            l_query := l_query || ' PIVOT ( sum(check_amount) AS AMT FOR plan_type IN ( ';
            l_count := 0;
            for x in (
                select
                    ben_plan_id,
                    plan_type
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and status <> 'R'
                    and trunc(plan_start_date) <= trunc(sysdate)
           --  AND STATUS = 'A'
                    and trunc(plan_end_date) >= trunc(sysdate)
                order by
                    ben_plan_id
            ) loop
                l_count := l_count + 1;
                if l_count = 1 then
                    l_query := l_query
                               || ''''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := 'SUM(NVL( '
                                   || x.plan_type
                                   || '_AMT, 0)) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := x.plan_type;
                else
                    l_query := l_query
                               || ','''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := l_field_sel
                                   || ','
                                   || 'SUM(NVL( '
                                   || x.plan_type
                                   || '_AMT, 0)) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := l_heading_sel
                                     || ','
                                     || x.plan_type;
                end if;

            end loop;

            l_query := l_query || '  )';
            l_query := 'SELECT CHECK_DATE,ACC_ID,ACC_NUM, '
                       || l_field_sel
                       || ' FROM ( '
                       || l_query
                       || ') GROUP BY CHECK_DATE,ACC_ID,ACC_NUM  ,CHECK_MM '
                       || 'ORDER BY CHECK_MM ';

            dbms_output.put_line('query ' || l_query);
        else
            l_query := null;
        end if;

        if l_count = 0 then
            return null;
        else
            return l_query;
        end if;
    exception
        when l_exception then
            return null;
    end get_fsa_ee_summary_sql;

    function get_fsa_ee_detail_sql (
        p_acc_id     in number,
        p_plan_start in varchar2,
        p_plan_end   in varchar2,
        p_start_date in varchar2,
        p_end_date   in varchar2
    ) return varchar2 is

        l_query       varchar2(32000);
        l_count       number := 0;
        l_field_sel   varchar2(3200);
        l_exception exception;
        l_heading_sel varchar2(3200);
    begin
 --       EXECUTE IMMEDIATE 'alter SESSION set nls_date_format=''DD-MON-YY''';

        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) = p_plan_start
                and trunc(plan_end_date) = p_plan_end
        ) loop
            l_count := x.cnt;
        end loop;
--   PC_LOG.LOG_ERROR('FSA_EE_DETAIL_SQL:QUERY ','Begin ');

        for x in (
            select
                count(*)
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) = p_plan_start
                and trunc(plan_end_date) = p_plan_end
            group by
                plan_type
            having
                count(*) > 1
        ) loop
            raise l_exception;
        end loop;

        if l_count > 0 then
            l_query := 'SELECT  TO_CHAR(a.fee_date,''MM/DD/YYYY'') check_date
                        , b.acc_id
                        , b.acc_num
                        , a.plan_type
                        , sum(NVL(a.AMOUNT,0)+NVL(a.AMOUNT_ADD,0)) check_amount
                  FROM income a
                     , account b
                 WHERE a.acc_id = b.acc_id
                  AND a.fee_code = 11
                  AND  b.account_type = ''FSA'' ';
            if p_acc_id is not null then
                l_query := l_query || ' AND B.ACC_ID = :acc_id '; --|| p_acc_id;

            end if;
            l_query := l_query || ' AND TRUNC(a.fee_date) >= :start_date  ';
            l_query := l_query || ' AND TRUNC(a.fee_date) <= :end_date  ';
            l_query := l_query || ' GROUP BY TO_CHAR(a.fee_date,''MM/DD/YYYY'') , b.acc_id, b.acc_num, a.plan_type ';
            l_query := l_query || ' ORDER BY a.fee_date) ';
            l_query := l_query || ' PIVOT ( sum(check_amount) AS AMT FOR plan_type IN ( ';
            l_count := 0;
            for x in (
                select distinct
                    a.plan_type
                from
                    income  a,
                    account b
                where
                        a.acc_id = b.acc_id
                    and a.fee_code = 11
                    and b.account_type = 'FSA'
                    and b.acc_id = p_acc_id
                    and trunc(a.fee_date) >= nvl(p_start_date, p_plan_start)
                    and trunc(a.fee_date) <= nvl(p_end_date, p_plan_end)
            ) loop
                l_count := l_count + 1;
                if l_count = 1 then
                    l_query := l_query
                               || ''''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := 'SUM(NVL( '
                                   || x.plan_type
                                   || '_AMT, 0)) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := x.plan_type;
                else
                    l_query := l_query
                               || ','''
                               || x.plan_type
                               || ''''
                               || ' AS '
                               || x.plan_type;

                    l_field_sel := l_field_sel
                                   || ','
                                   || 'SUM(NVL( '
                                   || x.plan_type
                                   || '_AMT, 0)) '
                                   || x.plan_type
                                   || '_AMT';

                    l_heading_sel := l_heading_sel
                                     || ','
                                     || x.plan_type;
                end if;

            end loop;

            l_query := l_query || '  )';
            l_query := 'SELECT CHECK_DATE,ACC_ID,ACC_NUM,  '
                       || l_field_sel
                       || ' FROM ( '
                       || l_query
                       || ') GROUP BY CHECK_DATE,ACC_ID,ACC_NUM    '
                       || 'ORDER BY CHECK_DATE ';

 --  PC_LOG.LOG_ERROR('FSA_EE_DETAIL_SQL:QUERY ',l_query);

        else
            l_query := null;
        end if;

        if l_count = 0 then
            return null;
        else
            return l_query;
        end if;
    exception
        when l_exception then
            return null;
    end get_fsa_ee_detail_sql;

    function get_hra_ee_detail_sql (
        p_acc_id     in number,
        p_plan_start in varchar2,
        p_plan_end   in varchar2,
        p_start_date in varchar2,
        p_end_date   in varchar2
    ) return varchar2 is

        l_query       varchar2(32000);
        l_count       number := 0;
        l_field_sel   varchar2(3200);
        l_exception exception;
        l_heading_sel varchar2(3200);
    begin
 --       EXECUTE IMMEDIATE 'alter SESSION set nls_date_format=''DD-MON-YY''';

        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) = p_plan_start
                and trunc(plan_end_date) = p_plan_end
        ) loop
            l_count := x.cnt;
        end loop;
--   PC_LOG.LOG_ERROR('HRA_EE_DETAIL_SQL:QUERY ','Begin ');

        for x in (
            select
                count(*)
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status <> 'R'
                and trunc(plan_start_date) = p_plan_start
                and trunc(plan_end_date) = p_plan_end
            group by
                ben_plan_name
            having
                count(*) > 1
        ) loop
            raise l_exception;
        end loop;

        if l_count > 0 then
            l_query := 'SELECT  TO_CHAR(a.fee_date,''MM/DD/YYYY'') check_date
                        , b.acc_id
                        , b.acc_num
                        , c.ben_plan_name
                        , sum(NVL(a.AMOUNT,0)+NVL(a.AMOUNT_ADD,0)) check_amount
                  FROM income a
                     , account b
                     ,BEN_PLAN_ENROLLMENT_SETUP C
                 WHERE a.acc_id = b.acc_id
                  AND a.fee_code <> 12
                  AND  b.account_type = ''HRA''
                  AND C.STATUS       IN (''A'',''I'')
                  AND C.ACC_ID       = B.ACC_ID';
            if p_acc_id is not null then
                l_query := l_query || ' AND B.ACC_ID = :acc_id '; --|| p_acc_id;

            end if;
            l_query := l_query || ' AND TRUNC(a.fee_date) >= :start_date  ';
            l_query := l_query || ' AND TRUNC(a.fee_date) <= :end_date  ';
            l_query := l_query || ' GROUP BY TO_CHAR(a.fee_date,''MM/DD/YYYY'') , b.acc_id, b.acc_num, c.ben_plan_name ';
            l_query := l_query || ' ORDER BY a.fee_date) ';
            l_query := l_query || ' PIVOT ( sum(check_amount) AS AMT FOR ben_plan_name IN ( ';
            l_count := 0;
            for x in (
                select distinct
                    c.ben_plan_name
                from
                    income                    a,
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        a.acc_id = b.acc_id
                    and a.fee_code <> 12
                    and b.account_type = 'HRA'
                    and b.acc_id = p_acc_id
                    and c.status in ( 'A', 'I' )
                    and c.acc_id = b.acc_id
                    and trunc(a.fee_date) >= nvl(p_start_date, p_plan_start)
                    and trunc(a.fee_date) <= nvl(p_end_date, p_plan_end)
            ) loop
                l_count := l_count + 1;
                if l_count = 1 then
                    l_query := l_query
                               || ''''
                               || x.ben_plan_name
                               || ''''
                               || ' AS '
                               || x.ben_plan_name;

                    l_field_sel := 'SUM(NVL( '
                                   || x.ben_plan_name
                                   || '_AMT, 0)) '
                                   || x.ben_plan_name
                                   || '_AMT';

                    l_heading_sel := x.ben_plan_name;
                else
                    l_query := l_query
                               || ','''
                               || x.ben_plan_name
                               || ''''
                               || ' AS '
                               || x.ben_plan_name;

                    l_field_sel := l_field_sel
                                   || ','
                                   || 'SUM(NVL( '
                                   || x.ben_plan_name
                                   || '_AMT, 0)) '
                                   || x.ben_plan_name
                                   || '_AMT';

                    l_heading_sel := l_heading_sel
                                     || ','
                                     || x.ben_plan_name;
                end if;

            end loop;

            l_query := l_query || '  )';
            l_query := 'SELECT CHECK_DATE,ACC_ID,ACC_NUM,  '
                       || l_field_sel
                       || ' FROM ( '
                       || l_query
                       || ') GROUP BY CHECK_DATE,ACC_ID,ACC_NUM    '
                       || 'ORDER BY CHECK_DATE ';

 --  PC_LOG.LOG_ERROR('HRAEE_DETAIL_SQL:QUERY ',l_query);

        else
            l_query := null;
        end if;

        if l_count = 0 then
            return null;
        else
            return l_query;
        end if;
    exception
        when l_exception then
            return null;
    end get_hra_ee_detail_sql;

-- Start addition by Swamy for SQL Injection
    function get_pending_contribution (
        p_acc_id in number
    ) return contrib_tbl
        pipelined
        deterministic
    is
        l_record contrib_row;
    begin
        for x in (
            select
                rownum,
                transaction_id,
                acc_id,
                amount,
                fee_amount,
                total_amount,
                to_char(transaction_date, 'MM/DD/YYYY') transaction_date,
                status,
                scheduler_id
            from
                pending_contribution_v
            where
                acc_id = p_acc_id
            order by
                transaction_date desc
        ) loop
            l_record.rownum1 := x.rownum;
            l_record.transaction_id := x.transaction_id;
            l_record.acc_id := x.acc_id;
            l_record.amount := x.amount;
            l_record.fee_amount := x.fee_amount;
            l_record.total_amount := x.total_amount;
            l_record.transaction_date := x.transaction_date;
            l_record.status := x.status;
            l_record.scheduler_id := x.scheduler_id; -- added by Joshi for 9382

            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_pending_contribution;

    function get_processed_contribution (
        p_acc_id in number,
        p_year   varchar2
    ) return contrib_tbl
        pipelined
        deterministic
    is
        l_record contrib_row;
    begin
        for x in (
            select
                er.check_number,
                er.list_bill,
                er.transaction_id,
                er.acc_id,
                er.amount,
                er.fee_amount,
                nvl(er.amount, 0) + nvl(er.fee_amount, 0) posted_amount,
                er.check_amount,
                to_char(er.check_date, 'MM/DD/YYYY')      check_date,
                er.pay_type,
                er.payment_method,
                er.refund_amount,
                a.scheduler_id
            from
                er_processed_contribution_v er,
                ach_transfer                a
            where
                    er.acc_id = p_acc_id
                and er.transaction_id = a.transaction_id (+)
                and trunc(to_char(er.check_date, 'YYYY')) = p_year
        )       -- Added by Jaggi #9382
         loop
            l_record.check_number := x.check_number;
            l_record.list_bill := x.list_bill;
            l_record.transaction_id := x.transaction_id;  /*Ticket#7840 */
            l_record.acc_id := x.acc_id;
            l_record.amount := x.amount;
            l_record.posted_amount := x.posted_amount;
            l_record.check_amount := x.check_amount;
            l_record.check_date := x.check_date;
            l_record.pay_type := x.pay_type;
            l_record.payment_method := x.payment_method;
            l_record.refund_amount := x.refund_amount;
            l_record.fee_amount := x.fee_amount; /*Ticket#7840 */
            l_record.scheduler_id := x.scheduler_id;  -- added by Joshi for 9382
            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_processed_contribution;

    function get_cancelled_contribution (
        p_acc_id in number
    ) return contrib_tbl
        pipelined
        deterministic
    is
        l_record contrib_row;
    begin
        for x in (
            select
                rownum,
                er.transaction_id,
                er.acc_id,
                er.amount,
                er.fee_amount,
                nvl(er.amount, 0) + nvl(er.fee_amount, 0)  posted_amount,
                er.bank_acct_id,
                er.total_amount,
                er.status_message,
                er.reason_code,
                to_char(er.transaction_date, 'MM/DD/YYYY') transaction_date,
                a.scheduler_id
            from
                cancelled_contribution_v er,
                ach_transfer             a
            where
                    er.acc_id = p_acc_id
                and er.transaction_id = a.transaction_id (+)
        ) loop
            l_record.rownum1 := x.rownum;
            l_record.transaction_id := x.transaction_id;
            l_record.acc_id := x.acc_id;
            l_record.amount := x.amount;
            l_record.fee_amount := x.fee_amount;
            l_record.posted_amount := x.posted_amount;
            l_record.bank_acct_id := x.bank_acct_id;
            l_record.total_amount := x.total_amount;
            l_record.status_message := x.status_message;
            l_record.reason_code := x.reason_code;
            l_record.transaction_date := x.transaction_date;
            l_record.scheduler_id := x.scheduler_id; -- added by Joshi for 9382

            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_cancelled_contribution;
-- End of addition by Swamy for SQL Injection
end fsa_online_summary;
/

