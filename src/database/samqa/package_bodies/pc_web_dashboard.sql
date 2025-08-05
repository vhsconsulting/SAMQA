create or replace package body samqa.pc_web_dashboard as

    function get_broker_info (
        p_brokr_id varchar2
    ) return tbl_brkr
        pipelined
    is
        rec tbl_brkr;
    begin
        select
            substr(name, 1, 30),             --employer name
            cnt,             -- employer dashboard
            round(cnt * 100 / sum(cnt)
                              over(),
                  1)--total amount
        bulk collect
        into rec
        from
            (
                select
                    e.name
                    || '('
                    || ae.account_type
                    || ')'          name,
                    count(a.acc_id) cnt
                from
                    enterprise e,
                    person     p,
                    account    a,
                    account    ae
                where
                        e.entrp_id = p.entrp_id
                    and p.pers_id = a.pers_id
                    and e.entrp_id = ae.entrp_id
                    and ae.broker_id = p_brokr_id
                group by
                    e.name
                    || '('
                    || ae.account_type
                    || ')'
            )
        order by
            2 desc;

        for i in 1..rec.last loop
            pipe row ( rec(i) );
        end loop;

    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
    end get_broker_info;

    function get_employer_info (
        p_entrp_id   in number,
        p_entrp_code in varchar2
    ) return tbl_rec_dash
        pipelined
        deterministic
    is
        l_rec rec_dash;
        l_cnt number := 0;--l_ben_plan_id NUMBER;l_entrp_code VARCHAR2(30);
    begin
        for x in (
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                b.plan_code,
                c.plan_name,
                a.entrp_id,
                b.acc_id,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                enterprise a,
                account    b,
                plan_codes c
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                  -- and (account_type='HSA' or (account_type!='HSA' and account_status=1))
               --Employer Online Portal
               --Commented bcoz HSA acct show up on portfolio page bcoz we hard code
               --plan code while enrollment(FOr HSA acct we need to have status as 1)
               --Also we show Active accounts
                --We need to show all accts where enrollment complete.So complete flag gives that.Valid for all kind of accts
                and ( account_status in ( 1, 3 )
                      and complete_flag = 1 ) -- added by jaggi #11229
                and p_entrp_id is not null
                and replace(a.entrp_code, '-') in (
                    select
                        replace(entrp_code, '-')
                    from
                        enterprise
                    where
                        entrp_id = p_entrp_id
                )
            union
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                b.plan_code,
                c.plan_name,
                a.entrp_id,
                b.acc_id,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                enterprise a,
                account    b,
                plan_codes c
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
               -- and (account_type='HSA' or (account_type!='HSA' and account_status=1))
               --Employer Online Portal
               --Commented bcoz HSA acct show up on portfolio page bcoz we hard code
               --plan code while enrollment(FOr HSA acct we need to have status as 1)
               --Also we show Active  accounts
              --We need to show all accts where enrollment complete.So complete flag gives that.Valid for all kind of accts
                and ( account_status in ( 1, 3 )
                      and complete_flag = 1 ) -- added by jaggi #11229
                and replace(a.entrp_code, '-') = replace(p_entrp_code, '-')
        ) loop
            l_rec := null;
            l_rec.acc_num := x.acc_num;
            l_rec.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
            l_rec.product_type := x.account_type;
            l_rec.show_account_online := x.show_account_online;   -- Added by Swamy for Ticket#9332 on 06/11/2020

                -- Added By Joshi for 10430.
            l_rec.inactive_plan_flag := 'N';
            if x.acc_id is not null then
                for y in (
                    select
                        max(plan_end_date) plan_end_date
                    from
                        account                   a,
                        ben_plan_enrollment_setup b
                    where
                            a.acc_id = b.acc_id
                        and a.acc_id = x.acc_id
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                ) loop
                    if ( sysdate - y.plan_end_date ) > 365 then
                        l_rec.inactive_plan_flag := 'Y';
                    end if;
                end loop;
            end if;

            if x.account_type in ( 'COBRA', 'HSA', 'LSA', 'ACA', 'CMP',
                                   'RB' ) then     -- ACA Added by Swamy for Ticket#10844 -- Added by Swamy for Ticket#9912
                l_rec.employee_count := nvl(
                    pc_entrp.count_active_person(x.entrp_id),
                    0
                );                                 --  RB Added by jaggi for Ticket#11689
                l_rec.product_type := x.account_type;
                  -- l_rec.plan_type    :=  X.ACCOUNT_TYPE;

                l_rec.plan_name := pc_lookups.get_account_type(x.account_type);
                select
                    plan_name
                into l_rec.plan_type
                from
                    plans
                where
                    plan_code = x.plan_code;

                pipe row ( l_rec );
            else
                for xx in (
                    select --COUNT ( bp.acc_id ) cnt
--                           , TO_CHAR(e.plan_start_date,'MM/DD/YYYY')||'-'||TO_CHAR(e.plan_end_date,'MM/DD/YYYY') PLAN_YEAR
                        e.plan_start_date,
                        e.plan_end_date,
                        decode(e.product_type,
                               'HRA',
                               e.ben_plan_name
--                                 , PC_LOOKUPS.GET_FSA_PLAN_TYPE(E.PLAN_TYPE)) PLAN_NAME
                               ,
                               replace(
                            pc_lookups.get_fsa_plan_type(e.plan_type),
                            e.product_type
                        )) plan_name,
                        e.maximum_election,
                        e.ben_plan_id,
                        e.transaction_limit,
                        e.plan_type
                    from
                        ben_plan_enrollment_setup bp,
                        ben_plan_enrollment_setup e
                         --    ACCOUNT C, PERSON D /* we do not want ees */
                    where
                            e.acc_id = x.acc_id
                        and e.status = 'A'
                        and nvl(bp.status, 'A') != 'R'
                       --   AND D.PERS_ID = C.PERS_ID(+) AND D.ENTRP_ID(+) = E.ENTRP_ID
                        and e.ben_plan_id_main is null
                         --Removed on 05/2017 to display plans with no ees also
                       --  AND c.acc_id=bp.acc_id--Added 01/19/2016(sk)
                        and e.plan_end_date + nvl(e.grace_period, 0) + nvl(e.runout_period_days, 0) >= sysdate
                        and e.ben_plan_id = bp.ben_plan_id_main (+)
                        and e.plan_end_date > trunc(sysdate, 'rr')
                        and e.plan_type <> 'NDT' --Pier#2739
                    group by --d.entrp_id,
--                        TO_CHAR(e.plan_start_date,'MM/DD/YYYY')||'-'||TO_CHAR(e.plan_end_date,'MM/DD/YYYY')
                        e.plan_start_date,
                        e.plan_end_date,
                        decode(e.product_type,
                               'HRA',
                               e.ben_plan_name,
                               replace(
                            pc_lookups.get_fsa_plan_type(e.plan_type),
                            e.product_type
                        )),
                        e.maximum_election,
                        e.ben_plan_id,
                        e.transaction_limit,
                        e.plan_type
                    order by
                        e.plan_start_date,
                        plan_type
                ) loop
                      --When we comment the above line,we need to recalculate the
                      --count of ees associated
                    select
                        count(1)
                    into l_rec.employee_count
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id_main = xx.ben_plan_id;

                       --l_rec.employee_count  := XX.CNT;
--                       l_rec.plan_year       := XX.PLAN_YEAR;
                    l_rec.plan_year := to_char(xx.plan_start_date, 'MM/DD/YYYY')
                                       || '-'
                                       || to_char(xx.plan_end_date, 'MM/DD/YYYY');-- PLAN_YEAR
                    l_rec.plan_type := xx.plan_type;
                    l_rec.plan_name := xx.plan_name;
                       --l_rec.plan_type    := XX.plan_type;
                        -- added by jaggi 10430
                    if l_rec.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                        l_rec.inactive_plan_flag := null;
                    end if;

                    for xxx in (
                        select
                            max(annual_election) max_election
                        from
                            ben_plan_coverages
                        where
                            ben_plan_id = xx.ben_plan_id
                    ) loop
                        l_rec.annual_election := xxx.max_election;
                    end loop;

                    if l_rec.annual_election is null then
                        l_rec.annual_election := xx.maximum_election;
                    end if;

                    if
                        l_rec.annual_election is null
                        and xx.plan_type in ( 'TRN', 'PKG' )
                    then
                        l_rec.annual_election := nvl(xx.transaction_limit,
                                                     pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', xx.plan_type, sysdate)) * 12;
                    end if;

                    select
                        sum(decode(coverage_type, 'SINGLE', annual_election, 0)),
                              --sum(decode(coverage_type,'SINGLE',0,annual_election))
                        sum(decode(coverage_type, 'EE_FAMILY', annual_election, 0))
                             /* Ticket#3425 -- Family shud be mapped to EE_FAMILY */
                    into
                        l_rec.single,
                        l_rec.family
                    from
                        ben_plan_coverages
                    where
                        ben_plan_id = xx.ben_plan_id;--and s.product_type--xx.plan_name = 'HRA'

                    pipe row ( l_rec );
                end loop;
            end if;

        end loop;
    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
            dbms_output.put_line(sqlerrm);
    end get_employer_info;

    function get_employee_info (
        p_acc_id in number,
        p_ssn    in varchar2
    ) return tbl_rec_dash
        pipelined
        deterministic
    is
        l_rec rec_dash;
        l_cnt number := 0;--l_ben_plan_id NUMBER;l_entrp_code VARCHAR2(30);
    begin
        for x in (
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                b.plan_code,
                c.plan_name,
                b.acc_id,
                a.pers_id,
                replace(a.ssn, '-') ssn,
                a.person_type    -- Added by Swamy for Ticket#9656 on 24/03/2021
                ,
                b.account_status
            from
                person     a,
                account    b,
                plan_codes c
            where
                    a.pers_id = b.pers_id
                and b.plan_code = c.plan_code
                --and(account_type='HSA'or (account_type!='HSA'and account_status=1))   -- Commented by Swamy for Ticket#9332
                -- AND (b.account_type='HSA' OR (b.account_type!='HSA' AND (b.account_status=1 OR (b.account_status=4 AND b.show_account_online = 'Y'))))   -- Added by Swamy for Ticket#9332
                and ( ( account_type = 'HSA'
                        and account_status <> 4 )
                      or ( account_type not in ( 'COBRA', 'HSA' )
                           and account_status = 1 )
                      or ( account_type = 'COBRA'
                           and account_status = 1 )
                      or ( account_type <> 'COBRA'
                           and b.account_status = 4
                           and b.show_account_online = 'Y' ) )
                and p_acc_id is not null
                and replace(a.ssn, '-') in (
                    select
                        replace(ssn, '-')
                    from
                        person  d, account e
                    where
                            d.pers_id = e.pers_id
                        and e.acc_id = b.acc_id        -- added by jaggi on 04/07/2023
                        and e.acc_id = p_acc_id
                )
            union
            select
                b.account_type,
                b.acc_num,
                b.start_date,
                b.plan_code,
                c.plan_name,
                b.acc_id,
                a.pers_id,
                replace(a.ssn, '-') ssn,
                a.person_type    -- Added by Swamy for Ticket#9656 on 24/03/2021
                ,
                b.account_status
            from
                person     a,
                account    b,
                plan_codes c
            where
                    a.pers_id = b.pers_id
                and b.plan_code = c.plan_code
                --and(account_type='HSA'or (account_type!='HSA'and account_status=1))   -- Commented by Swamy for Ticket#9332
               -- AND (b.account_type='HSA' OR (b.account_type!='HSA' AND (b.account_status=1 OR (b.account_status=4 AND b.show_account_online = 'Y'))))  -- Added by Swamy for Ticket#9332
                and ( ( account_type = 'HSA'
                        and account_status <> 4 )
                      or ( account_type not in ( 'COBRA', 'HSA' )
                           and account_status = 1 )
                      or ( account_type = 'COBRA'
                           and account_status = 1 )
                      or ( account_type <> 'COBRA'
                           and b.account_status = 4
                           and b.show_account_online = 'Y' ) )
                and p_ssn is not null
                and p_acc_id is null
                and replace(a.ssn, '-') = replace(p_ssn, '-')
        ) loop
            l_rec := null;
            if x.account_type = 'COBRA' then
                if x.person_type = 'SPM' then     -- Start Added by Swamy for Ticket#9656 on 24/03/2021
                    for xx in (
                        select
                            *
                        from
                            table ( pc_cobrapoint_migration.get_spm_sso(x.ssn) )
                    ) loop
                        l_rec.acc_num := x.acc_num;
                        l_rec.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    end loop;
                else   -- End of Addition by Swamy for Ticket#9656 on 24/03/2021
                    for xx in (
                        select
                            *
                        from
                            table ( pc_cobrapoint_migration.get_qb_sso(x.ssn) )
                    ) loop
                        if x.account_status = 1 then
                            l_rec.acc_num := x.acc_num;
                            l_rec.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                        end if;
                    end loop;
                end if;

                if
                    l_rec.acc_num is null
                    and x.account_status = 1
                then -- added by vanitha to support SAM MOVE
                    l_rec.acc_num := x.acc_num;
                    l_rec.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                end if; -- end of vanitha

            else
                l_rec.acc_num := x.acc_num;
                l_rec.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
            end if;

            if x.account_type not in ( 'HRA', 'FSA' ) then
                l_rec.product_type := x.account_type;
                l_rec.available_balance := pc_account.acc_balance(x.acc_id);
                l_rec.debit_card_bal := pc_account.acc_balance_card(x.acc_id);
                l_rec.disbursement := nvl(
                    pc_account_details.get_disbursement_total(x.acc_id,
                                                              trunc(
                                               trunc(sysdate, 'YYYY'),
                                               'YYYY'
                                           ),
                                                              sysdate),
                    0.00
                );

                l_rec.plan_name := pc_lookups.get_account_type(x.account_type);
                pipe row ( l_rec );
            else
                for xx in (
                    select
                        to_char(e.plan_start_date, 'MM/DD/YYYY')
                        || '-'
                        || to_char(e.plan_end_date, 'MM/DD/YYYY') plan_year,
                        e.plan_start_date,
                        e.plan_end_date,
                        e.plan_type,
                        decode(e.product_type,
                               'HRA',
                               e.ben_plan_name,
                               replace(
                            pc_lookups.get_fsa_plan_type(e.plan_type),
                            product_type
                        ))                                        plan_name,
                        e.annual_election,
                        case
                            when e.effective_end_date is not null
                                 and e.effective_end_date >= sysdate
                                 and e.runout_period_term = 'CPE' then
                                e.effective_end_date + e.runout_period_days
                            when e.effective_end_date is not null
                                 and e.effective_end_date >= sysdate
                                 and e.runout_period_term = 'CYE' then
                                e.plan_end_date + e.runout_period_days
                            else
                                e.plan_end_date + e.runout_period_days + e.grace_period
                        end                                       effective_end_date,
                        ben_plan_id
                    from
                        person                    d,
                        account                   k,
                        ben_plan_enrollment_setup e
                    where
                            d.pers_id = k.pers_id
                        and k.acc_id = x.acc_id
                        and k.acc_id = e.acc_id
                        and nvl(e.effective_end_date, sysdate) + nvl(runout_period_days, 0) >= trunc(sysdate)
                        and e.plan_end_date + nvl(grace_period, 0) + nvl(runout_period_days, 0) >= sysdate
                        and k.account_type = x.account_type
                        and status = 'A'
                        and plan_type <> 'NDT'  /* Ticket#2739 */
                     /*   GROUP BY --d.entrp_id,
                          e.plan_start_date,e.plan_end_date
                          --, E.PRODUCT_TYPE
                          ,E.PLAN_TYPE
                         , DECODE(E.PRODUCT_TYPE ,'HRA',E.BEN_PLAN_NAME
                                 , PC_LOOKUPS.GET_FSA_PLAN_TYPE(E.PLAN_TYPE))
                         , e.MAXIMUM_ELECTION*/
                ) loop
                      --IF TRUNC(XX.effective_end_date) >= TRUNC(SYSDATE) THEN
                    l_rec.plan_year := xx.plan_year;
                    l_rec.product_type := x.account_type;
                    l_rec.plan_type := xx.plan_type;
                    l_rec.plan_name := xx.plan_name;
                    if l_rec.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                        l_rec.disbursement := nvl(
                            pc_account_details.get_disbursement_total_by_plan(x.acc_id,
                                                                              trunc(sysdate, 'YYYY'),
                                                                              xx.plan_end_date,
                                                                              xx.plan_type),
                            0.00
                        );
                    else
                        l_rec.disbursement := nvl(
                            pc_account_details.get_disbursement_total_by_plan(x.acc_id, xx.plan_start_date, xx.plan_end_date, xx.plan_type
                            ),
                            0.00
                        );
                    end if;

                    l_rec.annual_election := xx.annual_election;
                    l_rec.available_balance := pc_account.new_acc_balance(x.acc_id, xx.plan_start_date, xx.plan_end_date, x.account_type
                    , xx.plan_type);
                       --select sum(decode(coverage_type,'SINGLE',  annual_election,0)),
                       --       sum(decode(coverage_type,'SINGLE',0,annual_election))
                       --  into l_rec.single,l_rec.family
                       --  from ben_plan_coverages
                       -- where ben_plan_id    = xx.ben_plan_id;
                    pipe row ( l_rec );
                     --END IF;
                end loop;
            end if;

        end loop;
    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
            dbms_output.put_line(sqlerrm);
    end get_employee_info;

    function f_employer_hsa_contribution (
        p_entrp_id in number
    ) return tbl_graph
        pipelined
        deterministic
    is
        l_record rec_graph;
    begin
        for x in (
            select
                to_char(fee_date, 'RRMM')              fee_mon,
                sum(emp_deposit) + sum(er_fee_deposit) er_deposit
            from
                (
                    select
                        *
                    from
                        table ( pc_activity_statement.get_er_statement_detail(p_entrp_id,
                                                                              trunc(sysdate, 'YYYY')/*-365*/,
                                                                              trunc(sysdate)) )
                )
            group by
                to_char(fee_date, 'RRMM')
        ) loop
            l_record.amount := x.er_deposit;
            l_record.mnth_yr := x.fee_mon;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
    end f_employer_hsa_contribution;

    function f_employer_hsa_distribution (
        p_entrp_id in number
    ) return tbl_graph
        pipelined
        deterministic
    is
        l_record rec_graph;
    begin
        for x in (
            select
                to_date('01/'
                        || to_char(
                    add_months(sysdate,(level - 1)),
                    'MON'
                )
                        || '/'
                        || to_char(
                    trunc(sysdate, 'YYYY'),
                    'YYYY'
                ),
                        'DD-MON-YYYY')   as from_date,
                last_day(to_date('01/'
                                 || to_char(
                    add_months(sysdate,(level - 1)),
                    'MON'
                )
                                 || '/'
                                 || to_char(
                    trunc(sysdate, 'YYYY'),
                    'YYYY'
                ),
                         'DD-MON-YYYY')) as end_date,
                to_char(
                    add_months(sysdate,(level - 1)),
                    'MM'
                )                        as mm
            from
                dual
            connect by
                level <= 12
            order by
                mm
        ) loop
            l_record.amount := 0;
            for xx in (
                select
                    to_char(x.from_date, 'RRRRMM') fee_mon,
                    sum(nvl(
                        pc_account_details.get_disbursement_total(b.acc_id, x.from_date, x.end_date),
                        0
                    ))                             disb
                from
                    account b,
                    person  c
                where
                        c.pers_id = b.pers_id
                    and c.entrp_id = p_entrp_id
                group by
                    to_char(x.from_date, 'RRRRMM')
            ) loop
                if nvl(xx.disb, 0) > 0 then
                    l_record.amount := l_record.amount + nvl(xx.disb, 0);
                    l_record.mnth_yr := xx.fee_mon;
                    pipe row ( l_record );
                end if;
            end loop;

        end loop;
    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
    end f_employer_hsa_distribution;

    function f_er_fsa_hra_claim (
        p_entrp_id  in number,
        p_plan_type in varchar2
    ) return tbl_graph
        pipelined
        deterministic
    is
        l_record rec_graph;
    begin
        for x in (
            select
                to_char(d.from_date, 'RRRRMM') fee_mon,
                sum(f.amount)                  amount
            from
                (
                    select
                        to_date('01/'
                                || to_char(
                            add_months(sysdate,(level - 1)),
                            'MON'
                        )
                                || '/'
                                || to_char(
                            trunc(sysdate, 'YYYY'),
                            'YYYY'
                        ),
                                'DD-MON-YYYY')   as from_date,
                        last_day(to_date('01/'
                                         || to_char(
                            add_months(sysdate,(level - 1)),
                            'MON'
                        )
                                         || '/'
                                         || to_char(
                            trunc(sysdate, 'YYYY'),
                            'YYYY'
                        ),
                                 'DD-MON-YYYY')) as end_date,
                        to_char(
                            add_months(sysdate,(level - 1)),
                            'MM'
                        )                        as mm
                    from
                        dual
                    connect by
                        level <= 12
                    order by
                        mm
                )                         d,
                account                   b,
                person                    c,
                payment                   f,
                claimn                    e,
                ben_plan_enrollment_setup g
            where
                    c.pers_id = b.pers_id
                and c.entrp_id = p_entrp_id
                and f.acc_id = b.acc_id
                and b.acc_id = g.acc_id
                and e.claim_id = f.claimn_id
                and g.plan_type = p_plan_type
                and e.service_type = f.plan_type
                and e.plan_start_date = g.plan_start_date
                and e.plan_end_date = g.plan_end_date
                and trunc(f.pay_date) >= d.from_date
                and trunc(f.pay_date) <= d.end_date
            group by
                to_char(d.from_date, 'RRRRMM')
            order by
                to_char(d.from_date, 'RRRRMM')
        ) loop
            l_record.amount := x.amount;
            l_record.mnth_yr := x.fee_mon;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
    end f_er_fsa_hra_claim;

    function f_er_fsa_hra_funding (
        p_entrp_id  in number,
        p_plan_type in varchar2
    ) return tbl_graph
        pipelined
        deterministic
    is
        l_record rec_graph;
    begin
        pc_log.log_error('f_er_fsa_hra_funding', 'p_entrp_id' || p_entrp_id);
        for x in (
            select
                to_char(d.from_date, 'RRRRMM') fee_mon,
                sum(c.check_amount)            amount
            from
                (
                    select
                        to_date('01/'
                                || to_char(
                            add_months(sysdate,(level - 1)),
                            'MON'
                        )
                                || '/'
                                || to_char(
                            trunc(sysdate, 'YYYY'),
                            'YYYY'
                        ),
                                'DD-MON-YYYY')   as from_date,
                        last_day(to_date('01/'
                                         || to_char(
                            add_months(sysdate,(level - 1)),
                            'MON'
                        )
                                         || '/'
                                         || to_char(
                            trunc(sysdate, 'YYYY'),
                            'YYYY'
                        ),
                                 'DD-MON-YYYY')) as end_date,
                        to_char(
                            add_months(sysdate,(level - 1)),
                            'MM'
                        )                        as mm
                    from
                        dual
                    connect by
                        level <= 12
                    order by
                        mm
                )                 d,
                account           b,
                employer_deposits c
            where
                    c.entrp_id = p_entrp_id
                and b.entrp_id = c.entrp_id
                and c.plan_type = p_plan_type
                and c.reason_code in ( 11, 17 )--9.7.15 as per meeting with Vanitha
                and trunc(c.check_date) >= d.from_date
                and trunc(c.check_date) <= d.end_date
            group by
                to_char(d.from_date, 'RRRRMM')
            order by
                to_char(d.from_date, 'RRRRMM')
        ) loop
            l_record.amount := x.amount;
            l_record.mnth_yr := x.fee_mon;
            pc_log.log_error('f_er_fsa_hra_funding', 'l_record.amount' || l_record.amount);
            pc_log.log_error('f_er_fsa_hra_funding', 'l_record.mnth_yr' || l_record.mnth_yr);
            pipe row ( l_record );
        end loop;

    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
    end f_er_fsa_hra_funding;

    function f_ee_hsa_detail (
        p_acc_id in number
    ) return ee_hsa_detail_tbl
        pipelined
        deterministic
    is
        l_record ee_hsa_detail_rec;
    begin
        for x in (
            select
                pc_param.get_system_value('INDIVIDUAL_CONTRIBUTION',
                                          trunc(sysdate, 'YYYY')) +
                case
                    when trunc(months_between(sysdate, birth_date) / 12) >= 55 then
                            nvl(to_number(pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                                    trunc(sysdate, 'YYYY'))),
                                0)
                    else
                        0
                end
                single_limit,
                pc_param.get_system_value('FAMILY_CONTRIBUTION',
                                          trunc(sysdate, 'YYYY')) +
                case
                    when trunc(months_between(sysdate, birth_date) / 12) >= 55 then
                            nvl(to_number(pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                                    trunc(sysdate, 'YYYY'))),
                                0)
                    else
                        0
                end
                family_limit,
                nvl(
                    pc_account_details.get_disbursement_total(acc_id,
                                                              trunc(sysdate, 'YYYY'),
                                                              sysdate),
                    0.00
                )       disb_ytd,
                nvl(
                    pc_account_details.get_current_year_total(acc_id,
                                                              trunc(sysdate, 'YYYY'),
                                                              sysdate,
                                                              a.start_date),
                    0.00
                )       receipt_ytd,
                c.plan_type
            from
                account a,
                person  b,
                insure  c
            where
                account_type in ( 'HSA', 'LSA' )   -- Added by Swamy for Ticket#9912 on 10/08/2021
                and a.pers_id = b.pers_id
                and b.pers_id = c.pers_id
                and a.acc_id = p_acc_id
        ) loop
            if x.plan_type = 0 then
                l_record.single_contrib_limit := nvl(x.single_limit, 3350);
            else
                l_record.famly_contrib_limit := nvl(x.family_limit, 6650);
            end if;

            l_record.disbursement_ytd := x.disb_ytd;
            l_record.receipt_ytd := x.receipt_ytd;
            l_record.catchup := pc_param.get_system_value('CATCHUP_CONTRIBUTION', sysdate);
            pipe row ( l_record );
        end loop;
    end f_ee_hsa_detail;

    function f_ee_hra_fsa_detail (
        p_acc_id in number
    ) return ee_hra_fsa_detail_tbl
        pipelined
        deterministic
    is
        l_record ee_hra_fsa_detail_rec;
    begin
        for x in (
            select
                to_char(e.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(e.plan_end_date, 'MM/DD/YYYY')         plan_year,
                e.plan_start_date,
                e.plan_end_date,
                e.plan_type,
                decode(e.product_type,
                       'HRA',
                       e.ben_plan_name,
                       pc_lookups.get_fsa_plan_type(e.plan_type)) plan_name,
                e.annual_election,
                nvl(
                    pc_account_details.get_disbursement_total_by_plan(k.acc_id,
                                                                      trunc(sysdate, 'YYYY'),
                                                                      sysdate,
                                                                      e.plan_type),
                    0.00
                )                                                 disb_ytd,
                k.account_type
            from
                person                    d,
                account                   k,
                ben_plan_enrollment_setup e
            where
                    d.pers_id = k.pers_id
                and k.acc_id = p_acc_id
                and k.acc_id = e.acc_id
                and e.status = 'A'
                and e.plan_end_date + nvl(grace_period, 0) + nvl(runout_period_days, 0) >= sysdate
        ) loop
            l_record.plan_name := x.plan_name;
            l_record.plan_year := x.plan_year;
            l_record.annual_election := x.annual_election;
            l_record.disbursement_ytd := x.disb_ytd;
            l_record.available_balance := pc_account.new_acc_balance(p_acc_id, x.plan_start_date, x.plan_end_date, x.account_type, x.plan_type
            );

            pipe row ( l_record );
        end loop;
    end f_ee_hra_fsa_detail;

    function f_employee_hsa_distribution (
        p_acc_id in number
    ) return tbl_graph
        pipelined
        deterministic
    is
        l_record rec_graph;
    begin
        for x in (
            select
                sum(d.amount)                 disb,
                to_char(d.pay_date, 'RRRRMM') fee_mon
            from
                account b,
                claimn  c,
                payment d
            where
                    c.pers_id = b.pers_id
                and b.acc_id = p_acc_id
                and d.acc_id = b.acc_id
                and trunc(d.pay_date) >= trunc(sysdate, 'YYYY')
                and d.claimn_id = c.claim_id
            group by
                to_char(d.pay_date, 'RRRRMM')
        ) loop
            l_record.amount := x.disb;
            l_record.mnth_yr := x.fee_mon;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error($$plsql_unit, dbms_utility.format_error_backtrace || sqlerrm);
    end f_employee_hsa_distribution;

    function get_broker_enterprise (
        p_broker_id    number,
        p_account_type varchar2 default null,
        p_tax          varchar2 default null,
        p_client_name  in varchar2 default null
    )  -- Added by Swamy for Ticket#12129 02/05/2024
     return tbl_broker_person
        pipelined
    is

        rec                 rec_broker_person;
        l_count             number := 0;
        l_renew             varchar2(2) := null;
        l_flag              varchar2(2) := 'N';
        l_cnt_deny          number := 0;
        l_renewal_flag      varchar2(2);
        l_renewal           number := 0;
        l_broker_req_status varchar2(30);
        l_authorize_req_id  number;
    begin
        pc_log.log_error('get_broker_enterprise', 'p_broker_id..' || p_broker_id);
        pc_log.log_error('get_broker_enterprise', 'p_account_type..' || p_account_type);
        pc_log.log_error('get_broker_enterprise', 'p_tax..' || p_tax);
        if p_account_type in ( 'HSA', 'HRA', 'FSA', 'LSA' )
           or p_account_type is null then
            for x in (
                select
                    name,
                    acc_num,
                    acc_id,
                    allow_broker_enroll,
                    allow_broker_renewal,
                    allow_broker_invoice,
                    status,
                    effective_end_date,
                    entrp_code,
                    account_type,
                    allow_bro_upd_pln_doc,    --  8728 rprabu 21/02/2020
                    allow_broker_plan_amend,  -- Joshi 11081
                    entrp_id                   -- Added by Jaggi
                from
                    (
                        select
                            substr(name, 1, 40)                             name,
                            d.acc_num,
                            d.acc_id,
                            ap.allow_broker_enroll,
                            ap.allow_broker_renewal,
                            ap.allow_broker_invoice,
                            ap.allow_bro_upd_pln_doc,       ---  8728 rprabu 21/02/2020
                            pc_lookups.get_account_status(d.account_status) status,
                            d.end_date                                      effective_end_date,
                            a.entrp_code,
                            d.account_type,
                            allow_broker_plan_amend, -- Joshi 11081
                            d.entrp_id               -- Added by Jaggi
                        from
                            enterprise         a--,person b,account c --sk updated on 12/18/2020 to remove the dependency on person table
                            ,
                            account            d,
                            account_preference ap
                        where
                                d.broker_id = p_broker_id
                            and d.account_type in ( 'HSA', 'HRA', 'FSA', 'LSA' ) -- uncommented by swamy for Ticket#9703
                            and a.entrp_id = d.entrp_id
                -- and  d.account_status = 1  --Ticket#6834 
                            and d.account_status in ( 1, 3 )  -- Added by Joshi for PROD bug. allow pending activation accounts also 
                            and d.account_type = nvl(p_account_type, d.account_type)
                            and a.entrp_code = nvl(p_tax, a.entrp_code)
                            and a.entrp_id = ap.entrp_id
                            and d.acc_id = ap.acc_id
                            and upper(a.name) like upper('%'
                                                         || p_client_name
                                                         || '%')  -- Added by Swamy for Ticket#12129 02/05/2024
                        group by
                            name,
                            d.acc_num,
                            d.acc_id,
                            ap.allow_broker_enroll,
                            ap.allow_broker_renewal,
                            ap.allow_broker_invoice,
                            ap.allow_bro_upd_pln_doc,        ---  8728 rprabu 21/02/2020
                            d.account_status,
                            d.end_date,
                            a.entrp_code,
                            d.account_type,
                            ap.allow_broker_plan_amend -- Joshi 11081
                            ,
                            d.entrp_id         -- Added by Jaggi
                        order by
                            2
                    )
            ) loop
                rec.name := x.name;
                rec.acc_num := x.acc_num;
                rec.acc_id := x.acc_id;
                rec.status := x.status;
                rec.effective_end_date := x.effective_end_date;
                rec.tax_id := x.entrp_code;
                rec.sso_enabled := 'N';
                rec.account_type := x.account_type;
                rec.renewal_deadline := null;
                if x.account_type in ( 'HRA', 'FSA', 'LSA' ) then
                    rec.show_renewal_link := 'N';
                    rec.contact_team_url := pc_sales_team.get_cust_srvc_rep_url_for_er(x.entrp_id);         -- Added by Jaggi
                    rec.contact_phone_num := pc_sales_team.get_cust_srvc_rep_phone_num_for_er(x.entrp_id);   -- Added by Jaggi
                    rec.contact_email := pc_sales_team.get_cust_srvc_rep_email_for_er(x.entrp_id);       -- Added by Jaggi
                    rec.contact_name := pc_sales_team.get_cust_srvc_rep_name_for_er(x.entrp_id);        -- Added by Jaggi
                    for k in (
                        select
                            renewal_deadline
                        from
                            table ( pc_web_er_renewal.get_er_plans(x.acc_id) )
                        where
                                renewed = 'N'
                            and declined = 'N'
                        order by
                            plan_type
                    ) loop
                        if x.allow_broker_renewal = 'Y' then
                            rec.show_renewal_link := x.allow_broker_renewal;
                        end if;

                        rec.renewal_deadline := ( k.renewal_deadline + 1 );
                        exit;
                    end loop;

                else
                    rec.show_renewal_link := 'N';          
         -- Added by Jagg
                    rec.contact_team_url := 'https://outlook.office365.com/owa/calendar/HSADepartment@sterlingadministration.com/bookings/s/y4CjR1TunkOxeJ-Hi5foww2'
                    ;
                    rec.contact_phone_num := '(510) 496-8401';
                    rec.contact_email := 'HSA@sterlingadministration.com';
                    rec.contact_name := 'HSA Team';
                end if;

                rec.account_description := x.account_type;
                rec.show_enroll_link := x.allow_broker_enroll;
                if x.allow_broker_invoice = 'Y'
                or x.allow_broker_renewal = 'Y'
                or x.allow_bro_upd_pln_doc = 'Y' then  ---  8728 rprabu 21/02/2020
                    rec.show_enroll_link := 'Y';
                end if;

    -- Added by Joshi for 9902.
                pc_log.log_error('get_broker_enterprise', 'p_broker_id..' || p_broker_id);
                pc_log.log_error('get_broker_enterprise', 'x.acc_id..' || x.acc_id);
                l_broker_req_status := pc_broker.get_broker_authorize_req_info(p_broker_id, x.acc_id);
                if ( rec.show_enroll_link = 'Y'
                or rec.show_renewal_link = 'Y' )
                or l_broker_req_status = 'APPROVED' then
                    rec.broker_request_status := 'A';
                elsif l_broker_req_status = 'PENDING_FOR_APPROVAL' then
                    rec.broker_request_status := 'P';
                else
                    rec.broker_request_status := 'N';
                end if;

                rec.authorize_req_id := pc_broker.get_broker_authorize_req_id(p_broker_id, x.acc_id);
                if p_account_type = 'LSA'
                or x.account_type = 'LSA' then
                    rec.broker_request_status := null;
                end if;
    --code ends here Joshi for 9902.

                pc_log.log_error('get_broker_enterprise', 'l_broker_req_status..' || l_broker_req_status);
                pc_log.log_error('get_broker_enterprise', 'rec.acc_num..' || rec.acc_num);
                pipe row ( rec );
            end loop;
        end if;

        if p_account_type = 'COBRA'
        or p_account_type is null then
            for x in (
                select
                    name,
                    acc_num,
                    acc_id,
                    allow_broker_enroll,
                    allow_broker_renewal,
                    allow_broker_invoice,
                    allow_bro_upd_pln_doc   --- 9511 rprabu 30/09/2020
                    ,
                    status,
                    (
                        select
                            sum(nvl(amount, 0) + nvl(amount_add, 0))
                        from
                            income
                        where
                                income.contributor = entrp_id
                            and fee_date between trunc(start_date) and sysdate
                    ) cont,
                    entrp_code,
                    account_type,
                    account_status,
                    renewal_resubmit_assigned_to  -- Added by swamy for Ticket#11636
                    ,
                    renewal_resubmit_flag         -- Added by swamy for Ticket#11636
                    ,
                    entrp_id                      --  Added by Jaggi   
                from
                    (
                        select
                            substr(name, 1, 40)                             name,
                            d.acc_num,
                            d.acc_id,
                            ap.allow_broker_enroll,
                            ap.allow_broker_renewal,
                            ap.allow_broker_invoice--,count(b.pers_id) ee_count,
                            ,
                            ap.allow_bro_upd_pln_doc  --- 9511 rprabu 30/09/2020
                            ,
                            pc_lookups.get_account_status(d.account_status) status,
                            d.account_status,
                            d.start_date,
                            d.entrp_id,
                            a.entrp_code,
                            d.account_type,
                            d.renewal_resubmit_assigned_to   -- Added by swamy for Ticket#11636
                            ,
                            d.renewal_resubmit_flag         -- Added by swamy for Ticket#11636
                        from
                            enterprise         a,
                            account            d,
                            account_preference ap
                        where
                                d.broker_id = p_broker_id
                            and d.account_type in ( 'COBRA' )
                            and a.entrp_id = d.entrp_id
                --and d.account_status = 1 --Ticket#6834 
                            and d.account_status in ( 1, 3 )
                            and a.entrp_code = nvl(p_tax, a.entrp_code)
                            and a.entrp_id = ap.entrp_id
                            and d.acc_id = ap.acc_id
                            and upper(a.name) like upper('%'
                                                         || p_client_name
                                                         || '%')  -- Added by Swamy for Ticket#12129 02/05/2024
                        group by
                            name,
                            d.acc_num,
                            d.acc_id,
                            ap.allow_broker_enroll,
                            ap.allow_broker_renewal,
                            ap.allow_broker_invoice,
                            ap.allow_bro_upd_pln_doc,  --- 9511 rprabu 30/09/2020
                            d.account_status,
                            d.start_date,
                            d.entrp_id,
                            a.entrp_code,
                            d.account_type,
                            d.account_status,
                            d.renewal_resubmit_assigned_to,
                            d.renewal_resubmit_flag         -- Added by swamy for Ticket#11636
                            ,
                            d.entrp_id         -- Added by Jaggi
                        order by
                            2
                    )
            ) loop
                rec.name := x.name;
                rec.acc_num := x.acc_num;
                rec.acc_id := x.acc_id;
                rec.contribution := format_money(nvl(x.cont, 0));
                rec.disbursement := 'N/A';
                rec.balance := 'N/A';
                rec.status := x.status;
                rec.show_renewal_link := 'N';
                rec.renewal_deadline := null;
                rec.renewal_resubmit_assigned_to := x.renewal_resubmit_assigned_to;  -- Added by Swamy for Ticket#11636
                rec.renewal_resubmit_assigned_to := x.renewal_resubmit_flag;         -- Added by swamy for Ticket#11636
                rec.contact_team_url := pc_sales_team.get_cust_srvc_rep_url_for_er(x.entrp_id);         -- Added by Jaggi
                rec.contact_phone_num := pc_sales_team.get_cust_srvc_rep_phone_num_for_er(x.entrp_id);   -- Added by Jaggi
                rec.contact_email := pc_sales_team.get_cust_srvc_rep_email_for_er(x.entrp_id);       -- Added by Jaggi
                rec.contact_name := pc_sales_team.get_cust_srvc_rep_name_for_er(x.entrp_id);        -- Added by Jaggi

                if x.account_type = 'COBRA' then
                    for j in (
                        select
                            renewal_deadline
                        from
                            table ( pc_web_compliance.get_er_plans(x.acc_id, x.account_type, null) )
                        where
                                declined = 'N'
                            and renewed = 'N'
                    ) loop
                        if x.allow_broker_renewal = 'Y' then
                            rec.show_renewal_link := x.allow_broker_renewal;
                        end if;

                        rec.renewal_deadline := ( j.renewal_deadline + 1 );
                    end loop;
                end if;

                rec.account_description := x.account_type;
                rec.show_enroll_link := x.allow_broker_enroll;
                if x.allow_broker_invoice = 'Y'
                or x.allow_broker_renewal = 'Y'
                or x.allow_bro_upd_pln_doc = 'Y' then
                    rec.show_enroll_link := 'Y';
                end if;

                rec.tax_id := x.entrp_code;
                rec.sso_enabled := 'N';
                rec.account_type := x.account_type;
                if x.account_status = 1 then
                    select
                        count(*)
                    into l_count
                    from
                        table ( pc_cobrapoint_migration.get_client_sso(x.entrp_code) );

                    if l_count > 0 then
                        rec.sso_enabled := 'Y';
                    end if;
                end if;

  -- Added by Joshi for 9902.
                l_broker_req_status := pc_broker.get_broker_authorize_req_info(p_broker_id, x.acc_id);
                if ( rec.show_enroll_link = 'Y'
                or rec.show_renewal_link = 'Y' )
                or l_broker_req_status = 'APPROVED' then
                    rec.broker_request_status := 'A';
                elsif l_broker_req_status = 'PENDING_FOR_APPROVAL' then
                    rec.broker_request_status := 'P';
                else
                    rec.broker_request_status := 'N';
                end if;

                rec.authorize_req_id := pc_broker.get_broker_authorize_req_id(p_broker_id, x.acc_id);
                if p_account_type = 'LSA'
                or x.account_type = 'LSA' then
                    rec.broker_request_status := null;
                end if;

                pipe row ( rec );
            end loop;
        end if;

        if p_account_type not in ( 'HSA', 'HRA', 'FSA', 'COBRA', 'LSA' )
           or p_account_type is null then
            for x in (
                select
                    name,
                    acc_num,
                    acc_id,
                    allow_broker_enroll,
                    allow_broker_renewal,
                    allow_broker_invoice,
                    status,
                    end_date,
                    entrp_code,
                    account_type,
                    allow_bro_upd_pln_doc ---  8728 rprabu 21/02/2020
                    ,
                    allow_broker_plan_amend -- Joshi 11081
                    ,
                    entrp_id
                from
                    (
                        select
                            substr(name, 1, 40)                             name,
                            d.acc_num,
                            d.acc_id,
                            ap.allow_broker_enroll,
                            ap.allow_broker_renewal,
                            ap.allow_broker_invoice,
                            ap.allow_bro_upd_pln_doc, ---  8728 rprabu 21/02/2020
                            pc_lookups.get_account_status(d.account_status) status,
                            end_date,
                            a.entrp_code,
                            d.account_type,
                            ap.allow_broker_plan_amend,   -- Joshi 11081
                            d.entrp_id                    -- Added by Jaggi
                        from
                            enterprise         a,
                            account            d,
                            account_preference ap
                        where
                                d.broker_id = p_broker_id
                            and a.entrp_id = d.entrp_id
                            and d.account_type not in ( 'HSA', 'HRA', 'FSA', 'COBRA', 'LSA' )
               -- Added for Ticket#6834 
             -- and D.ACCOUNT_status=1
                            and d.account_status in ( 1, 3 )  -- Added by Joshi for PROD bug. allow pending activation accounts also 
                            and d.account_type = nvl(p_account_type, d.account_type)
                            and a.entrp_code = nvl(p_tax, a.entrp_code)
                            and a.entrp_id = ap.entrp_id
                            and d.acc_id = ap.acc_id
                            and upper(a.name) like upper('%'
                                                         || p_client_name
                                                         || '%')  -- Added by Swamy for Ticket#12129 02/05/2024
                        group by
                            name,
                            d.acc_num,
                            d.acc_id,
                            ap.allow_broker_enroll,
                            ap.allow_broker_renewal,
                            ap.allow_broker_invoice,
                            ap.allow_bro_upd_pln_doc,             --  8728 rprabu 21/02/2020
                            d.account_status,
                            d.end_date,
                            a.entrp_code,
                            d.account_type,
                            ap.allow_broker_plan_amend -- Joshi 11081
                            ,
                            d.entrp_id         -- Added by Jaggi
                        order by
                            2
                    )
            ) loop
                l_flag := 'N';
                rec.name := x.name;
                rec.acc_num := x.acc_num;
                rec.acc_id := x.acc_id; -- Added by Joshi for 9902
                rec.status := x.status;
                rec.effective_end_date := x.end_date;
                rec.no_ee := 0;
                rec.contribution := 'N/A';
                rec.disbursement := 'N/A';
                rec.balance := 'N/A';
                rec.tax_id := x.entrp_code;
                rec.sso_enabled := 'N';
                rec.account_type := x.account_type;
                rec.contact_team_url := 'https://outlook.office365.com/owa/calendar/Compliance1@sterlingadministration.com/bookings/s/pXGjI9FQS0m0mArfpyNdgg2'
                ; -- Added by Jaggi
                rec.contact_phone_num := '(510) 723-1900';                                                -- Added by Jaggi
                rec.contact_email := 'Compliance@sterlingadministration.com';                         -- Added by Jaggi
                rec.contact_name := 'Compliance Team';         -- Added by Jaggi

                if x.account_type = 'ERISA_WRAP' then
                    rec.account_description := 'ERISA WRAP';
                elsif x.account_type = 'FORM_5500' then
                    rec.account_description := 'FORM 5500';
                else
                    rec.account_description := x.account_type;
                end if;

                rec.renewal_deadline := null;
                rec.show_renewal_link := 'N';
                if x.account_type in ( 'ERISA_WRAP', 'POP', 'FORM_5500' ) then
                    for x1 in (
                        select
                            renewal_deadline
                        from
                            table ( pc_web_compliance.get_er_plans(x.acc_id, x.account_type, x.entrp_code) )
                        where
                                declined = 'N'
                            and renewed = 'N'
                            and is_renewed = 'N'
                    ) loop
                        if x.allow_broker_renewal = 'Y' then
                            rec.show_renewal_link := x.allow_broker_renewal;
                        end if;

                        if x1.renewal_deadline is not null then
                            rec.renewal_deadline := ( x1.renewal_deadline + 1 );
                        end if;

                    end loop;
                end if;

   -- End of addition by Swamy for Ticket#9384
                rec.show_enroll_link := x.allow_broker_enroll;
  --IF x.allow_broker_invoice = 'Y' OR  x.allow_broker_renewal = 'Y' OR x.Allow_bro_upd_pln_Doc   = 'Y'  THEN   --- 8728 rprabu 21/02/2020
                if x.allow_broker_invoice = 'Y'
                or x.allow_broker_renewal = 'Y'
                or x.allow_bro_upd_pln_doc = 'Y'
                or x.allow_broker_plan_amend = 'Y' then    -- commented aboved and add line  Joshi 11081
                    rec.show_enroll_link := 'Y';
                end if;

  -- Added by Joshi for 9902. 
                l_broker_req_status := pc_broker.get_broker_authorize_req_info(p_broker_id, x.acc_id);
                if ( rec.show_enroll_link = 'Y'
                or rec.show_renewal_link = 'Y' )
                or l_broker_req_status = 'APPROVED' then
                    rec.broker_request_status := 'A';
                elsif l_broker_req_status = 'PENDING_FOR_APPROVAL' then
                    rec.broker_request_status := 'P';
                else
                    rec.broker_request_status := 'N';
                end if;

                rec.authorize_req_id := pc_broker.get_broker_authorize_req_id(p_broker_id, x.acc_id);
                if p_account_type = 'LSA'
                or x.account_type = 'LSA' then
                    rec.broker_request_status := null;
                end if;

                pipe row ( rec );
            end loop;
        end if;

    exception
        when others then
            pc_log.log_error('Get Broker Enterprise', sqlerrm);
    end get_broker_enterprise;

    function get_broker_person (
        p_broker_id    number,
        p_account_type varchar2 default null,
        p_tax          varchar2 default null
    ) return tbl_broker_person
        pipelined
    is
        rec rec_broker_person;
    begin
        pc_log.log_error('get_broker_person', 'p_broker_id' || p_broker_id);
        pc_log.log_error('get_broker_person', 'p_account_type' || p_account_type);
        pc_log.log_error('get_broker_person', 'p_tax' || p_tax);
        for x in (
            select
                acc_num,
                x.broker_id,
                x.name,
                sum(decode(d.reason_mode, 'I', amount, 'E', amount,
                           0))                                             contrib,
                sum(decode(d.reason_mode,
                           'P',
                           abs(d.amount),
                           'D',
                           abs(d.amount),
                           0))                                             disb,
                sum(decode(d.reason_mode, 'I', amount, 'E', amount,
                           0)) - sum(decode(reason_mode,
                                            'P',
                                            abs(amount),
                                            'D',
                                            abs(amount),
                                            0))                                             bal,
                effective_end_date                              effective_end_date,
                pc_lookups.get_account_status(c.account_status) status
            from
                (
                    select
                        broker_id,
                        effective_date,
                        a.pers_id,
                        first_name
                        || ' '
                        || last_name name,
                        effective_end_date
                    from
                        person             a,
                        broker_assignments b
                    where
                            a.pers_id = b.pers_id
                        and broker_id = p_broker_id
                        and a.ssn like '%'
                                       || nvl(p_tax, a.ssn)
                                       || '%'
                )                x,
                account          c,
                balance_register d
            where
                    x.pers_id = c.pers_id
                and c.acc_id = d.acc_id
                and account_status <> 5
                and account_type = nvl(p_account_type, account_type)
            group by
                acc_num,
                x.broker_id,
                x.name,
                c.acc_id,
                c.pers_id,
                effective_end_date,
                c.account_status
        ) loop
            rec.name := x.name;
            rec.acc_num := x.acc_num;
            rec.contribution := format_money(nvl(x.contrib, 0));
            rec.disbursement := format_money(nvl(x.disb, 0));
            rec.balance := format_money(nvl(x.bal, 0));
            rec.status := x.status;
            rec.effective_end_date := x.effective_end_date;
            pipe row ( rec );
        end loop;

    end get_broker_person;

-- added by Jaggi #11368
    function get_ga_enterprise (
        p_ga_id        in number,
        p_broker_id    in number,
        p_account_type varchar2 default null
    ) return tbl_ga_person
        pipelined
    is
        rec rec_ga_person;
    begin
        pc_log.log_error('get_ga_enterprise', 'p_ga_id..' || p_ga_id);
        pc_log.log_error('get_ga_enterprise', 'p_account_type..' || p_account_type);
        if p_account_type in ( 'FSA', 'HRA', 'COBRA', 'ERISA_WRAP' )
           or p_account_type is null then  -- Added by Swamy for Ticket#11920(11533 Sprint Ticket)
            for x in (
                select
                    a.name,
                    b.acc_id,
                    b.acc_num,
                    a.entrp_code,
                    b.account_type,
                    pc_lookups.get_account_status(b.account_status) status,
                    b.signature_account_status,
                    b.renewal_resubmit_assigned_to    -- Added by Swamy for Ticket#11636
                    ,
                    b.renewal_resubmit_flag           -- Added by Swamy for Ticket#11636
                    ,
                    b.renewed_date                    -- Added by Swamy for Ticket#11636
                from
                    enterprise         a,
                    account            b,
                    account_preference ap
                where
                        a.entrp_id = b.entrp_id
                    and account_type = nvl(p_account_type, account_type)
                    and ( ( p_ga_id is not null
                            and ga_id = p_ga_id )
                          or ( p_broker_id is not null
                               and broker_id = p_broker_id
                               and nvl(ap.allow_broker_renewal, 'N') = 'Y' ) )
                    and account_status in ( 1, 3 )
                    and account_type in ( 'FSA', 'HRA', 'COBRA', 'ERISA_WRAP' ) -- Erisa added by Jaggi 11533
                    and decline_date is null
                    and ap.acc_id = b.acc_id
            ) loop
                rec.name := x.name;
                rec.acc_id := x.acc_id;
                rec.acc_num := x.acc_num;
                rec.entrp_code := x.entrp_code;
                rec.status := x.status;
                rec.account_type := x.account_type;
                rec.show_renewal_link := 'N';
                rec.renewal_deadline := null;
                rec.authorize_req_id := pc_broker.get_broker_authorize_req_id(p_broker_id, x.acc_id);  -- Added by swamy for Ticket#11368(broker)
                rec.signature_account_status := x.signature_account_status;                             -- Added by swamy for Ticket#11368(broker)
                rec.renewal_resubmit_assigned_to := x.renewal_resubmit_assigned_to;              -- Added by swamy for Ticket#11636
                rec.renewal_resubmit_flag := x.renewal_resubmit_flag;                     -- Added by swamy for Ticket#11636
                if x.account_type in ( 'FSA', 'HRA' ) then
                    for k in (
                        select
                            to_char(renewal_deadline + 1, 'MM/DD/YYYY') renewal_deadline
                        from
                            table ( pc_web_er_renewal.get_er_plans(x.acc_id) )
                        where
                                renewed = 'N'
                            and declined = 'N'
                        order by
                            plan_type
                    ) loop
                        rec.show_renewal_link := 'Y';
                        rec.renewal_deadline := k.renewal_deadline;
                    end loop;
                elsif x.account_type = 'COBRA' then
                    rec.show_renewal_link := pc_web_compliance.emp_plan_renewal_disp_cobra(x.acc_id);
          -- Added by Swamy for Ticket#11517(11368 Dev Ticket)
                    for k in (
                        select
                            to_char(renewal_deadline + 1, 'MM/DD/YYYY') renewal_deadline
                        from
                            table ( pc_web_compliance.get_er_plans(x.acc_id, 'COBRA') )
                        where
                                renewed = 'N'
                            and declined = 'N'
                        order by
                            plan_type
                    ) loop
                        rec.renewal_deadline := k.renewal_deadline;
                    end loop;

                    if trunc(sysdate) < add_business_days(5,
                                                          nvl(x.renewed_date,
                                                              trunc(sysdate))) then  -- Added by swamy for Ticket#11636
                        rec.disable_resubmit_flag := 'N';
                    else
                        rec.disable_resubmit_flag := 'Y';
                    end if;

                elsif x.account_type = 'ERISA_WRAP' then                                                -- Erisa added by Jaggi 11533
                    rec.show_renewal_link := pc_web_compliance.emp_plan_renewal_disp_erisa(x.acc_id);  
          -- Added by Swamy for Ticket#11517(11368 Dev Ticket)
                    for k in (
                        select
                            to_char(renewal_deadline + 1, 'MM/DD/YYYY') renewal_deadline
                        from
                            table ( pc_web_compliance.get_er_plans(x.acc_id, 'ERISA_WRAP') )   -- Added ERISA_WRAP by Swamy for Ticket#11916/11926(11533 Sprint Ticket)
                        where
                                renewed = 'N'
                            and declined = 'N'
                        order by
                            plan_type
                    ) loop
                        rec.renewal_deadline := k.renewal_deadline;
                    end loop;

                    if trunc(sysdate) < add_business_days(5,
                                                          nvl(x.renewed_date,
                                                              trunc(sysdate))) then  -- Added by swamy for Ticket#11636
                        rec.disable_resubmit_flag := 'N';
                    else
                        rec.disable_resubmit_flag := 'Y';
                    end if;

                end if;

                pipe row ( rec );
            end loop;
        end if;

    end get_ga_enterprise;

end;
/


-- sqlcl_snapshot {"hash":"313ead685f43c22062ddb62401f56f5ddd0488fa","type":"PACKAGE_BODY","name":"PC_WEB_DASHBOARD","schemaName":"SAMQA","sxml":""}