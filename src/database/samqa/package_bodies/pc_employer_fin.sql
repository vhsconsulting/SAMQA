create or replace package body samqa.pc_employer_fin as

    procedure process_bal_parellel (
        p_entrp_id_from in number,
        p_entrp_id_to   in number
    ) is
    begin
        for x in (
            select
                entrp_id
            from
                account
            where
                account_type in ( 'HRA', 'FSA' )
                and entrp_id >= p_entrp_id_from
                and entrp_id <= p_entrp_id_to
        ) loop
            delete from employer_payments
            where
                transaction_source like 'CLAIM_PAYMENT%'
                and entrp_id = x.entrp_id;

            create_employer_payment(x.entrp_id, sysdate);
        end loop;
    end;

    procedure refresh_er_balance is
    begin
        for x in (
            select
                entrp_id
            from
                account
            where
                account_type in ( 'HRA', 'FSA' )
                and account_status = 1
                and entrp_id is not null
        ) loop
            create_employer_payment(x.entrp_id, sysdate);
        end loop;
    end;

    procedure calculate_interest (
        dat_from    in date default sysdate - 31,
        dat_to      in date default sysdate,
        entrp_id_in in number
    ) is
        l_interest  number;
        l_list_bill number;
    begin
        for x in (
            select
                b.acc_num,
                b.entrp_id,
                claim_reimbursed_by,
                a.plan_type
            from
                ben_plan_enrollment_setup a,
                account                   b
            where
                    b.entrp_id = nvl(entrp_id_in, b.entrp_id)
                and funding_options in ( '100%_FUND', '50%_FUND' )
                and a.entrp_id is not null
                and a.status in ( 'A', 'I' )
                and b.account_type in ( 'FSA', 'HRA' )
                and a.product_type = 'HRA'
                and a.plan_start_date <= dat_from
                and a.plan_end_date >= dat_to
                and a.entrp_id = b.entrp_id
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = a.acc_id
                        and plan_start_date > a.plan_end_date
                        and ben_plan_enrollment_setup.status in ( 'A', 'I' )
                )
                and not exists (
                    select
                        *
                    from
                        employer_deposits c
                    where
                            c.entrp_id = b.entrp_id
                        and c.reason_code = 8
                        and c.check_date = nvl(dat_to,
                                               trunc(sysdate, 'MM'))
                )
            union
            select
                b.acc_num,
                b.entrp_id,
                claim_reimbursed_by,
                a.plan_type
            from
                ben_plan_enrollment_setup a,
                account                   b
            where
                    b.entrp_id = nvl(entrp_id_in, b.entrp_id)
                and funding_options in ( '100%_FUND', '50%_FUND' )
                and a.entrp_id is not null
                and b.account_type in ( 'FSA', 'HRA' )
                and a.product_type = 'HRA'
                and a.plan_start_date <= dat_from
                and a.status in ( 'A', 'I' )
                and a.plan_end_date + nvl(a.runout_period_days, 0) + nvl(grace_period, 0) >= dat_to
                and a.entrp_id = b.entrp_id
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = a.acc_id
                        and plan_start_date > a.plan_end_date
                        and ben_plan_enrollment_setup.status in ( 'A', 'I' )
                )
                and not exists (
                    select
                        *
                    from
                        employer_deposits c
                    where
                            c.entrp_id = b.entrp_id
                        and c.reason_code = 8
                        and c.check_date = nvl(dat_to,
                                               trunc(sysdate, 'MM'))
                )
        ) loop
            l_interest := pc_employer_fin.get_er_interest(dat_from, dat_to, x.entrp_id, 'HRA');
            if l_interest > 0 then
                select
                    employer_deposit_seq.nextval
                into l_list_bill
                from
                    dual;

                insert into employer_deposits (
                    employer_deposit_id,
                    entrp_id,
                    list_bill,
                    check_number,
                    check_amount,
                    check_date,
                    posted_balance,
                    remaining_balance,
                    fee_bucket_balance,
                    reason_code,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    note,
                    pay_code,
                    plan_type
                ) values ( l_list_bill,
                           x.entrp_id,
                           l_list_bill,
                           l_list_bill,
                           l_interest,
                           nvl(dat_to,
                               trunc(sysdate, 'MM')),
                           l_interest,
                           0,
                           0,
                           8,
                           0,
                           sysdate,
                           0,
                           sysdate,
                           'Interest for '
                           || to_char(dat_from, 'MM/DD/YYYY')
                           || '-'
                           || to_char(dat_to, 'MM/DD/YYYY'),
                           9,
                           x.plan_type );

            end if;

        end loop;
    end calculate_interest;

    function get_employer_balance (
        p_entrp_id  in number,
        p_end_date  in date,
        p_plan_type in varchar2
    ) return number is
        l_amount number := 0;
    begin
        if p_plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
            for x in (
                select
                    sum(nvl(check_amount, 0)) check_amount
                from
                    employer_balances_v
                where
                        entrp_id = p_entrp_id
                    and plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' )
                    and transaction_date <= p_end_date
            ) loop
                l_amount := x.check_amount;
            end loop;
        end if;

        if p_plan_type = 'FSA' then
            for x in (
                select
                    sum(nvl(check_amount, 0)) check_amount
                from
                    employer_balances_v
                where
                        entrp_id = p_entrp_id
                    and plan_type in ( 'FSA', 'DCA', 'TRN', 'PKG', 'IIR',
                                       'LPF', 'UA1' )
                    and transaction_date <= p_end_date
            ) loop
                l_amount := x.check_amount;
            end loop;

        end if;

        if p_plan_type = 'COBRA' then
            for x in (
                select
                    sum(nvl(check_amount, 0)) check_amount
                from
                    cobra_employer_balances_v
                where
                        entrp_id = p_entrp_id
                    and transaction_date <= p_end_date
            ) loop
                l_amount := x.check_amount;
            end loop;
        end if;

        return nvl(l_amount, 0);
    end get_employer_balance;

    function get_er_interest (
        dat_from    in date default sysdate - 31,
        dat_to      in date default sysdate,
        entrp_in    in number default null  -- NULL means all accounts
        ,
        p_plan_type in varchar2
    ) return number is
    /*  */
        v_aid      number; -- current acc_id
        v_dat      date := dat_from - 1; -- start date
        v_dat8_end date := sysdate; -- after this date will NOT %%
        pre_date   date;
        pre_days   number;
        v_bal      number(15, 2);
        v_baledic  number(15, 2);
        v_rat      number(15, 4); -- %% anual rate
        v_pp       number(15, 2); -- %% for days
        v_ppm      number(15, 2) := 0; -- %% for month
        v_delta    number(15, 2);
        v_ch       number;
        cursor c1 is
        select
            a.entrp_id,
            check_amount,
            transaction_date,
            fee_name,
            pc_employer_fin.get_employer_balance(entrp_in, transaction_date, 'HRA') + pc_employer_fin.sum_er_interest(entrp_in, transaction_date
            , 'HRA') balance
        from
            employer_balances_v a,
            account             b
        where
                a.entrp_id = entrp_in
            and a.entrp_id = b.entrp_id
            and a.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' )
         --   AND   a.plan_type = p_plan_type
            and b.account_type in ( 'HRA', 'FSA' )
            and trunc(transaction_date) >= dat_from
            and trunc(transaction_date) <= dat_to
        union all
        select
            a.entrp_id,
            0,
            dat_to,
            'Interest',
            pc_employer_fin.get_employer_balance(entrp_in, dat_to, 'HRA') + pc_employer_fin.sum_er_interest(entrp_in, dat_to, 'HRA') balance
        from
            account                   a,
            ben_plan_enrollment_setup d,
            (
                select
                    add_months(
                        last_day(trunc(dat_from)),
                        rownum - 1
                    ) as dd
                from
                    all_objects
                where
                    rownum <= ( 1 + months_between(dat_to, dat_from) )
            )
        where
                a.entrp_id = entrp_in
            and a.account_type in ( 'HRA', 'FSA' )
            and a.entrp_id = d.entrp_id
            and d.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' )
            and d.status in ( 'A', 'I' )
         -- AND  d.plan_type = p_plan_type
            and d.plan_start_date <= dat_from
            and d.plan_end_date + nvl(grace_period, 0) + nvl(runout_period_days, 0) >= trunc(dat_to)
            and dd between d.plan_start_date and last_day(least(
                nvl(d.effective_end_date,
                    d.plan_end_date + nvl(grace_period, 0) + nvl(runout_period_days, 0)),
                dat_from
            ))
        order by
            3 asc;

    begin
        for r1 in c1 loop
            if ( v_aid is null ) then -- new acc
                v_aid := r1.entrp_id;
                v_ppm := 0;
                v_pp := 0;
                v_dat := dat_from;
            end if;

            pre_date := v_dat;
            v_dat := r1.transaction_date;
            pre_days := ( v_dat - pre_date ) + 1;
            dbms_output.put_line(' pre_days '
                                 || pre_days
                                 || ' v_dat '
                                 || v_dat
                                 || ' pre date '
                                 || pre_date);

            if r1.balance > 0 then
                v_pp := r1.balance * ( power(1 +.25 / 100, pre_days / 365) - 1 ); -- %% money for pre_days\
                dbms_output.put_line('entrp_id'
                                     || v_aid
                                     || ' balance '
                                     || r1.balance
                                     || ' v_pp '
                                     || v_pp
                                     || ' pre date '
                                     || pre_date);

                v_bal := r1.balance;
            end if;

            if v_pp > 0 then -- %% have a sense
                v_ppm := v_ppm + v_pp; -- sum days for month
            end if;
        end loop;

        return nvl(v_ppm, 0);
    end get_er_interest;

    function get_fee_balance (
        p_entrp_id in number
    ) return number is
        l_fee_balance number := 0;
    begin
        for x in (
            select
                entrp_id,
                check_amount,
                check_date transaction_date,
                a.reason_code
            from
                employer_deposits a,
                fee_names         b
            where
                    a.reason_code = b.fee_code
                and a.reason_code = 40
                and a.entrp_id = p_entrp_id
       /*     UNION ALL
          SELECT ENTRP_ID,
             - CHECK_AMOUNT,
              TRANSACTION_DATE,
              A.REASON_CODE
            FROM EMPLOYER_PAYMENTS A,
              PAY_REASON B
            WHERE A.REASON_CODE = B.REASON_CODE
            AND A.REASON_CODE  = 2
            and a.ENTRP_ID= P_ENTRP_ID
            AND trunc(TRANSACTION_DATE) >= (SELECT MIN(CHECK_DATE) FROM EMPLOYER_DEPOSITS C
                                            where REASON_CODE = 40
                                            AND A.ENTRP_ID= C.ENTRP_ID)*/
            order by
                3
        ) loop
            l_fee_balance := l_fee_balance + nvl(x.check_amount, 0);
        end loop;

        if l_fee_balance < 0 then
            l_fee_balance := 0;
        end if;
        return l_fee_balance;
    end get_fee_balance;

    function sum_er_interest (
        p_entrp_id  in number,
        p_end_date  in date,
        p_plan_type in varchar2
    ) return number is
        l_amount number;
    begin
        for x in (
            select
                entrp_id,
                sum(nvl(check_amount, 0)) check_amount
            from
                employer_deposits a
            where
                    a.reason_code = 8
                and entrp_id = p_entrp_id
                and ( ( p_plan_type = 'HRA'
                        and plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) )
                      or ( p_plan_type = 'FSA'
                           and plan_type in ( 'FSA', 'DCA', 'TRN', 'PKG', 'IIR',
                                              'LPF' ) ) )
                and check_date < p_end_date
            group by
                entrp_id
        ) loop
            l_amount := x.check_amount;
        end loop;

        return l_amount;
    end sum_er_interest;

    procedure arch_create_employer_payment (
        p_entrp_id in number,
        p_date     in date default null
    ) as
        l_exists varchar2(1);
        l_count  number;
    begin
        delete from employer_payments
        where
            transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH' )
            and entrp_id = p_entrp_id;

        for x in (
            select
                *
            from
                (
                    select
                        p.entrp_id,
                        sum(nvl(c.amount, 0)) pay_amount,
                        'CLAIM_PAYMENT_'
                        || to_char(
                            trunc(c.paid_date),
                            'MMDDYYYY'
                        )                     check_num,
                        reason_code,
                        trunc(c.paid_date)    paid_date,
                        p.service_type,
                        p.plan_start_date,
                        p.plan_end_date,
                        'CLAIM_PAYMENT'       transaction_source
                    from
                        account acc,
                        claimn  p,
                        payment c
                    where
                        acc.account_type in ( 'HRA', 'FSA' )
                        and acc.pers_id = p.pers_id
                        and p.claim_id = c.claimn_id
                        and p.service_type = c.plan_type
                        and c.acc_id = acc.acc_id
                        and p.takeover = 'N'
                        and c.paid_date is not null
                        and ( acc.payroll_integration is null
                              or acc.payroll_integration = 'N' )
                        and ( p_entrp_id is null
                              or p.entrp_id = p_entrp_id )
 -- AND (trunc(c.pay_date) = p_date or p_date is null and TRUNC(C.pay_date)  > SYSDATE-7 )
                    group by
                        p.entrp_id,
                        'CLAIM_PAYMENT_'
                        || to_char(
                            trunc(c.paid_date),
                            'MMDDYYYY'
                        ),
                        reason_code,
                        trunc(c.paid_date),
                        p.service_type,
                        p.plan_start_date,
                        p.plan_end_date
                    having
                        sum(nvl(c.amount, 0)) <> 0
                    union all
                    select
                        p.entrp_id,
                        sum(nvl(c.total_amount, 0)) pay_amount,
                        'PENDING_ACH_'
                        || to_char(
                            trunc(c.transaction_date),
                            'MMDDYYYY'
                        )                           check_num,
                        p.pay_reason,
                        trunc(c.transaction_date)   paid_date,
                        p.service_type,
                        p.plan_start_date,
                        p.plan_end_date,
                        'PENDING_ACH'               transaction_source
                    from
                        account      acc,
                        claimn       p,
                        ach_transfer c
                    where
                        acc.account_type in ( 'HRA', 'FSA' )
                        and acc.pers_id = p.pers_id
                        and p.claim_id = c.claim_id
                        and c.acc_id = acc.acc_id
                        and p.takeover = 'N'
                        and c.status in ( 1, 2 )
  -- AND C.PAID_DATE IS NOT NULL
                        and ( acc.payroll_integration is null
                              or acc.payroll_integration = 'N' )
                        and ( p_entrp_id is null
                              or p.entrp_id = p_entrp_id )
 -- AND (trunc(c.pay_date) = p_date or p_date is null and TRUNC(C.pay_date)  > SYSDATE-7 )
                    group by
                        p.entrp_id,
                        'PENDING_ACH_'
                        || to_char(
                            trunc(c.transaction_date),
                            'MMDDYYYY'
                        ),
                        p.pay_reason,
                        p.service_type,
                        p.plan_start_date,
                        p.plan_end_date,
                        trunc(c.transaction_date)
                    having
                        sum(nvl(c.total_amount, 0)) <> 0
                    union all
                    select
                        p.entrp_id,
                        sum(nvl(c.amount, 0)) pay_amount,
                        'PENDING_CHECK_'
                        || to_char(
                            trunc(e.check_date),
                            'MMDDYYYY'
                        )                     check_num,
                        reason_code,
                        trunc(e.check_date)   paid_date,
                        p.service_type,
                        p.plan_start_date,
                        p.plan_end_date,
                        'PENDING_CHECK'       transaction_source
                    from
                        account acc,
                        claimn  p,
                        payment c,
                        checks  e
                    where
                        acc.account_type in ( 'HRA', 'FSA' )
                        and acc.pers_id = p.pers_id
                        and p.claim_id = c.claimn_id
                        and p.service_type = c.plan_type
                        and e.entity_type = 'CLAIMN'
                        and e.entity_id = p.claim_id
                        and acc.acc_id = e.acc_id
                        and c.acc_id = acc.acc_id
                        and e.status in ( 'READY', 'SENT' )
                        and p.takeover = 'N'
                        and c.paid_date is null
                        and e.mailed_date is null
                        and ( acc.payroll_integration is null
                              or acc.payroll_integration = 'N' )
                        and ( p_entrp_id is null
                              or p.entrp_id = p_entrp_id )
 -- AND (trunc(c.pay_date) = p_date or p_date is null and TRUNC(C.pay_date)  > SYSDATE-7 )
                    group by
                        p.entrp_id,
                        'PENDING_CHECK_'
                        || to_char(
                            trunc(e.check_date),
                            'MMDDYYYY'
                        ),
                        reason_code,
                        trunc(e.check_date),
                        p.service_type,
                        p.plan_start_date,
                        p.plan_end_date
                    having
                        sum(nvl(c.amount, 0)) <> 0
                )
            order by
                paid_date desc
        ) loop
            l_exists := 'N';
            if x.transaction_source = 'CLAIM_PAYMENT' then
                select
                    count(*)
                into l_count
                from
                    employer_payments
                where
                        check_date = x.paid_date
                    and entrp_id = x.entrp_id
                    and transaction_source = 'CLAIM_PAYMENT'
                    and plan_type = x.service_type
                    and plan_start_date = x.plan_start_date
                    and plan_end_date = x.plan_end_date
                    and reason_code = x.reason_code
                    and check_number = x.check_num;

                if l_count > 0 then
        /*  for xxx in (
            SELECT *
            FROM  employer_payments
           WHERE  check_date = x.paid_date
            AND   entrp_id=x.entrp_id
            AND   transaction_source = 'CLAIM_PAYMENT'
            AND   plan_type = x.service_type
            AND   plan_start_date = x.plan_start_date
            AND   plan_end_date = x.plan_end_date
            AND   reason_code = x.reason_code
            AND   check_number = x.check_num)
         loop
           insert into employer_payment_log
           values ( xxx.entrp_id, xxx.check_date,xxx.plan_type,xxx.plan_start_date,xxx.plan_end_date,xxx.reason_code,xxx.check_number
                ,NVL(xxX.check_amount,0),sysdate,'before update');

         end loop;
         */
                    l_exists := 'Y';
                end if;
            end if;

            if l_exists = 'Y' then
                update employer_payments
                set
                    check_amount = nvl(x.pay_amount, 0)
                where
                        check_date = x.paid_date
                    and entrp_id = x.entrp_id
                    and transaction_source = 'CLAIM_PAYMENT'
                    and plan_type = x.service_type
                    and plan_start_date = x.plan_start_date
                    and plan_end_date = x.plan_end_date
                    and reason_code = x.reason_code
                    and check_number = x.check_num;
        /* insert into employer_payment_log
        values ( x.entrp_id, x.paid_date,x.service_type,x.plan_start_date,x.plan_end_date,x.reason_code,x.check_num
                ,NVL(X.pay_amount,0),sysdate,'after update');*/

            else
                insert into employer_payments (
                    employer_payment_id,
                    entrp_id,
                    check_amount,
                    check_number,
                    check_date,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    note,
                    reason_code,
                    transaction_date,
                    plan_type,
                    transaction_source,
                    plan_start_date,
                    plan_end_date
                ) values ( employer_payments_seq.nextval,
                           x.entrp_id,
                           nvl(x.pay_amount, 0),
                           x.check_num,
                           x.paid_date,
                           sysdate,
                           0,
                           sysdate,
                           0,
                           pc_lookups.get_reason_name(x.reason_code),
                           x.reason_code,
                           x.paid_date,
                           x.service_type,
                           x.transaction_source,
                           x.plan_start_date,
                           x.plan_end_date );

            end if;

        end loop;

    end arch_create_employer_payment;

    procedure create_employer_payment (
        p_entrp_id in number,
        p_date     in date default null
    ) as

        l_exists              varchar2(1);
        l_count               number;
        cursor zero_pay_cur (
            p_entrp_id in number
        ) is
        select
            a.entrp_id,
            sum(a.pay_amount),
            a.check_num,
            a.reason_code,
            a.paid_date,
            a.service_type,
            a.plan_start_date,
            a.plan_end_date,
            a.transaction_source,
            null employer_payment_id,
            null
        from
            employer_payment_detail a
        where
                a.entrp_id = p_entrp_id
            and a.status <> 'VOID'
            and employer_payment_id = 0
            and a.transaction_source = 'CLAIM_PAYMENT'
        group by
            a.entrp_id,
            a.check_num,
            a.reason_code,
            a.paid_date,
            a.service_type,
            a.plan_start_date,
            a.plan_end_date,
            a.transaction_source
        having
            sum(a.pay_amount) = 0
        order by
            a.entrp_id;

        l_pay_tab             pay_tab;
        l_pay_count           number := 0;
        l_employer_payment_id number;
    begin
        dbms_output.put_line('ENTRP ID ' || p_entrp_id);
      -- COLLECT THE DETAIL
        create_employer_payment_detail(p_entrp_id);

      -- IF THE TRANSACTION AMOUNT IS ZERO WE WILL NOT INSERT INTO employer_payments
      -- WE WILL MARK THE STATUS AS VOID since the transaction is wash off
        open zero_pay_cur(p_entrp_id);
        loop
            fetch zero_pay_cur
            bulk collect into l_pay_tab limit 1000;
            dbms_output.put_line('l_pay_tab  ' || l_pay_tab.count);
            forall i in 1..l_pay_tab.count
                update employer_payment_detail a
                set
                    status = 'VOID'
                where
                        a.entrp_id = l_pay_tab(i).entrp_id
                    and a.check_num = l_pay_tab(i).check_num
                    and a.reason_code = l_pay_tab(i).reason_code
                    and a.service_type = l_pay_tab(i).service_type
                    and a.plan_start_date = l_pay_tab(i).plan_start_date
                    and a.plan_end_date = l_pay_tab(i).plan_end_date
                    and a.transaction_source = l_pay_tab(i).transaction_source
                    and a.paid_date = l_pay_tab(i).paid_date;

            exit when l_pay_tab.count < 1000;
        end loop;

        close zero_pay_cur;
        update employer_payment_detail a
        set
            status = 'APPROVED'
        where
                transaction_source = 'PENDING_CHECK'
            and entrp_id = p_entrp_id
            and exists (
                select
                    *
                from
                    checks b
                where
                        a.check_number = b.check_number
                    and b.mailed_date is not null
            );

        update employer_payment_detail a
        set
            status = 'VOID'
        where
                entrp_id = p_entrp_id
            and transaction_source = 'PENDING_CHECK'
            and exists (
                select
                    *
                from
                    checks b
                where
                        a.check_number = b.check_number
                    and b.status in ( 'PURGE_AND_REISSUE', 'PURGED' )
            );

        update employer_payment_detail a
        set
            status = 'VOID'
        where
                entrp_id = p_entrp_id
            and transaction_source in ( 'PENDING_ACH', 'PENDING_CHECK' )
            and exists (
                select
                    *
                from
                    claimn b
                where
                        a.claim_id = b.claim_id
                    and b.claim_status in ( 'DENIED', 'ERROR' )
            );

        update employer_payment_detail a
        set
            status = 'APPROVED'
        where
                entrp_id = p_entrp_id
            and transaction_source = 'PENDING_ACH'
            and exists (
                select
                    *
                from
                    ach_transfer b
                where
                        a.transaction_id = b.transaction_id
                    and b.status = 3
            );

        update employer_payment_detail a
        set
            status = 'VOID'
        where
                entrp_id = p_entrp_id
            and transaction_source = 'PENDING_ACH'
            and exists (
                select
                    *
                from
                    ach_transfer b
                where
                        a.transaction_id = b.transaction_id
                    and b.status = 9
            );

        update employer_payment_detail ed
        set
            status = 'VOID'
        where
                entrp_id = p_entrp_id
            and status <> 'VOID'
            and exists (
                select
                    *
                from
                    claimn c
                where
                        c.claim_id = ed.claim_id
                    and c.claim_status = 'CANCELLED'
            );
          -- delete the void transactions
        delete from employer_payments a
        where
                entrp_id = p_entrp_id
            and transaction_source in ( 'CLAIM_PAYMENT', 'PENDING_ACH', 'PENDING_CHECK' )
            and not exists (
                select
                    *
                from
                    employer_payment_detail b
                where
                        a.employer_payment_id = b.employer_payment_id
                    and status = 'PROCESSED'
            );

         -- Pending Check , Pending ACH process
         -- Vanitha: Between claim payment and Pending Check/Pending ACH there would be some redundancy
         -- I just want to keep it there to avoid any confusions
      /*   FOR XX IN (SELECT SUM(a.PAY_AMOUNT)  AMOUNT
                          , ENTRP_ID
                          , REASON_CODE
                          , SERVICE_TYPE
                          , PAID_DATE
                          , PLAN_START_DATE
                          , PLAN_END_DATE
                          , TRANSACTION_SOURCE
                          , CHECK_NUM
                        FROM  EMPLOYER_PAYMENT_DETAIL a
                        WHERE a.TRANSACTION_SOURCE IN ('PENDING_CHECK', 'PENDING_ACH')
                        AND   A.STATUS = 'PROCESSED'
                        and   a.entrp_id = P_ENTRP_ID
                        GROUP BY ENTRP_ID
                          , REASON_CODE
                          , SERVICE_TYPE
                          , PAID_DATE
                          , PLAN_START_DATE
                          , PLAN_END_DATE
                          , TRANSACTION_SOURCE
                          , CHECK_NUM)
         LOOP
                SELECT COUNT(*) INTO L_PAY_COUNT
                FROM EMPLOYER_PAYMENTS
                WHERE   TRANSACTION_SOURCE = XX.TRANSACTION_SOURCE
                 AND    ENTRP_ID = XX.ENTRP_ID
                 AND    REASON_CODE = XX.REASON_CODE
                 AND    plan_TYPE = XX.SERVICE_TYPE
                 AND    CHECK_DATE  = XX.PAID_DATE
                 AND    PLAN_START_DATE = XX.PLAN_START_DATE
                 AND    PLAN_END_DATE   = XX.PLAN_END_DATE
                 AND    CHECK_NUMber = XX.CHECK_NUM;

               IF L_PAY_COUNT > 0 THEN
                 IF XX.AMOUNT = 0 THEN
                    DELETE FROM EMPLOYER_PAYMENTS
                     WHERE  TRANSACTION_SOURCE = XX.TRANSACTION_SOURCE
                     AND    ENTRP_ID = XX.ENTRP_ID
                     AND    REASON_CODE = XX.REASON_CODE
                     AND    plan_TYPE = XX.SERVICE_TYPE
                     AND    CHECK_DATE  = XX.PAID_DATE
                     AND    PLAN_START_DATE = XX.PLAN_START_DATE
                     AND    PLAN_END_DATE   = XX.PLAN_END_DATE
                     AND    CHECK_NUMber = XX.CHECK_NUM;

                 ELSE
                         UPDATE EMPLOYER_PAYMENTS
                         SET    CHECK_AMOUNT = XX.AMOUNT
                            ,   LAST_UPDATE_DATE = SYSDATE
                         WHERE  TRANSACTION_SOURCE = XX.TRANSACTION_SOURCE
                         AND    CHECK_AMOUNT <> XX.AMOUNT
                         AND    ENTRP_ID = XX.ENTRP_ID
                         AND    REASON_CODE = XX.REASON_CODE
                         AND    plan_TYPE = XX.SERVICE_TYPE
                         AND    CHECK_DATE  = XX.PAID_DATE
                         AND    PLAN_START_DATE = XX.PLAN_START_DATE
                         AND    PLAN_END_DATE   = XX.PLAN_END_DATE
                         AND    CHECK_NUMber = XX.CHECK_NUM;

                 END IF;
             END IF;
         END LOOP;*/
        for xx in (
            select
                sum(
                    case
                        when a.status = 'APPROVED' then
                            0
                        else
                            pay_amount
                    end
                ) amount,
                a.employer_payment_id
            from
                employer_payment_detail a,
                employer_payments       b
            where
                    a.employer_payment_id = b.employer_payment_id
                and b.transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH' )
                and a.status <> 'VOID'
                and a.entrp_id = p_entrp_id
            group by
                a.employer_payment_id
            order by
                a.employer_payment_id
        ) loop
            if xx.amount = 0 then
                delete from employer_payments
                where
                    employer_payment_id = xx.employer_payment_id;

            else
                update employer_payments
                set
                    check_amount = xx.amount,
                    last_update_date = sysdate
                where
                    employer_payment_id = xx.employer_payment_id;

            end if;
        end loop;

        for xx in (
            select distinct
                entrp_id
            from
                employer_payment_detail a
            where
                a.transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH' )
                and a.status = 'PROCESSED'
                and a.entrp_id = p_entrp_id
        ) loop
            update_er_payment_detail(p_entrp_id);
        end loop;

        for xx in (
            select
                sum(a.pay_amount) amount,
                entrp_id,
                reason_code,
                service_type,
                paid_date,
                plan_start_date,
                plan_end_date,
                transaction_source,
                check_num,
                trunc(creation_date)
            from
                employer_payment_detail a
            where
                a.transaction_source in ( 'CLAIM_PAYMENT', 'PENDING_CHECK', 'PENDING_ACH' )
                and a.status = 'PROCESSED'
                and a.entrp_id = p_entrp_id
                and employer_payment_id = 0
            group by
                entrp_id,
                reason_code,
                service_type,
                paid_date,
                plan_start_date,
                plan_end_date,
                transaction_source,
                check_num,
                trunc(creation_date)
        ) loop
            if xx.amount <> 0 then
                insert into employer_payments (
                    employer_payment_id,
                    entrp_id,
                    check_amount,
                    check_number,
                    check_date,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    note,
                    reason_code,
                    transaction_date,
                    plan_type,
                    transaction_source,
                    plan_start_date,
                    plan_end_date
                ) values ( employer_payments_seq.nextval,
                           xx.entrp_id,
                           nvl(xx.amount, 0),
                           xx.check_num,
                           xx.paid_date,
                           sysdate,
                           0,
                           sysdate,
                           0,
                           pc_lookups.get_reason_name(xx.reason_code),
                           xx.reason_code,
                           xx.paid_date,
                           xx.service_type,
                           xx.transaction_source,
                           xx.plan_start_date,
                           xx.plan_end_date );

            end if;
        end loop;

        for xx in (
            select distinct
                entrp_id
            from
                employer_payment_detail a
            where
                a.transaction_source in ( 'CLAIM_PAYMENT', 'PENDING_CHECK', 'PENDING_ACH' )
                and a.status = 'PROCESSED'
                and a.entrp_id = p_entrp_id
                and a.employer_payment_id = 0
        ) loop
            update_er_payment_detail(p_entrp_id);
        end loop;

    end create_employer_payment;

    procedure create_employer_payment_detail (
        p_entrp_id in number,
        p_date     in date default null
    ) as
    begin
         -- INSERT THE CLAIM DETAILS
        insert into employer_payment_detail (
            entrp_id,
            pay_amount,
            check_num,
            reason_code,
            paid_date,
            service_type,
            plan_start_date,
            plan_end_date,
            transaction_source,
            change_num,
            employer_payment_id,
            creation_date,
            last_updated_date,
            payment_notes,
            claim_id,
            status,
            product_type
        )
            select
                p.entrp_id,
                nvl(c.amount, 0)   pay_amount,
                'CLAIM_PAYMENT_'
                || to_char(
                    trunc(c.paid_date),
                    'MMDDYYYY'
                )                  check_num,
                reason_code,
                trunc(c.paid_date) paid_date,
                p.service_type,
                p.plan_start_date,
                p.plan_end_date,
                'CLAIM_PAYMENT'    transaction_source,
                c.change_num,
                0                  employer_payment_id,
                c.creation_date,
                c.last_updated_date,
                c.note,
                p.claim_id,
                'PROCESSED',
                pc_lookups.get_meaning(p.service_type, 'FSA_HRA_PRODUCT_MAP')
            from
                account acc,
                payment c,
                claimn  p
            where
                ( p.entrp_id = p_entrp_id )
                and p.claim_id = c.claimn_id
                and p.service_type = c.plan_type
                and p.takeover = 'N'
                and c.paid_date is not null
                and c.acc_id = acc.acc_id
                and acc.pers_id = p.pers_id
                and acc.account_type in ( 'HRA', 'FSA' )
                and ( acc.payroll_integration is null
                      or acc.payroll_integration = 'N' )
                and not exists (
                    select
                        *
                    from
                        employer_payment_detail ep
                    where
                            ep.change_num = c.change_num
                        and ep.transaction_source = 'CLAIM_PAYMENT'
                );

        -- INSERT THE CLAIM DETAILS
    /*     INSERT INTO EMPLOYER_PAYMENT_DETAIL
         (ENTRP_ID,PAY_AMOUNT,CHECK_NUM,REASON_CODE,PAID_DATE,SERVICE_TYPE,PLAN_START_DATE,PLAN_END_DATE
         ,TRANSACTION_SOURCE,CHANGE_NUM,EMPLOYER_PAYMENT_ID,CREATION_DATE,LAST_UPDATED_DATE,PAYMENT_NOTES
         ,CLAIM_ID,STATUS)
         SELECT   P.ENTRP_ID
                , NVL(C.AMOUNT,0) PAY_AMOUNT
                , 'CLAIM_PAYMENT_'||TO_CHAR(TRUNC(C.PAY_DATE),'MMDDYYYY') CHECK_NUM
                , REASON_CODE
                , trunc(C.PAY_DATE) PAID_DATE
                , P.SERVICE_TYPE
                , P.PLAN_START_DATE
                , P.PLAN_END_DATE
                , 'CLAIM_PAYMENT' TRANSACTION_SOURCE
                , C.CHANGE_NUM
                , 0 EMPLOYER_PAYMENT_ID
                , C.CREATION_DATE
                , C.LAST_UPDATED_DATE
                , 'Purged check '||c.note
                , p.claim_id
                , 'PROCESSED'
           FROM  ACCOUNT ACC,
                 CLAIMN P,
                 PAYMENT C
           WHERE ACC.ACCOUNT_TYPE IN ('HRA','FSA')
           AND  P.CLAIM_STATUS IN ('PAID','PARTIALLY_PAID')
           AND ACC.PERS_ID         = P.PERS_ID
           AND P.CLAIM_ID          = C.CLAIMN_ID
           AND P.SERVICE_TYPE      = C.PLAN_TYPE
           AND C.ACC_ID            = ACC.ACC_ID
           AND C.PAID_DATE IS  NULL
           AND P.TAKEOVER = 'N'
           AND C.PAID_DATE IS  NULL
           AND (P.ENTRP_ID = P_ENTRP_ID  )
	         AND   EXISTS ( SELECT * FROM CHECKS WHERE ENTITY_ID = p.CLAIM_ID AND STATUS = 'PURGED')
           AND  (ACC.PAYROLL_INTEGRATION IS NULL OR ACC.PAYROLL_INTEGRATION = 'N')
           AND   NOT EXISTS ( SELECT * FROM EMPLOYER_PAYMENT_DETAIL EP
                              WHERE EP.CHANGE_NUM  = C.CHANGE_NUM and EP.TRANSACTION_SOURCE = 'CLAIM_PAYMENT');*/

         -- INSERT PENDING ACH DETAILS
        insert into employer_payment_detail (
            entrp_id,
            pay_amount,
            check_num,
            reason_code,
            paid_date,
            service_type,
            plan_start_date,
            plan_end_date,
            transaction_source,
            transaction_id,
            employer_payment_id,
            creation_date,
            last_updated_date,
            payment_notes,
            claim_id,
            status,
            product_type
        )
            select
                p.entrp_id,
                nvl(c.amount, 0)          pay_amount,
                'PENDING_ACH_'
                || to_char(
                    trunc(c.transaction_date),
                    'MMDDYYYY'
                )                         check_num,
                p.pay_reason,
                trunc(c.transaction_date) paid_date,
                p.service_type,
                p.plan_start_date,
                p.plan_end_date,
                'PENDING_ACH'             transaction_source,
                c.transaction_id,
                0                         employer_payment_id,
                c.creation_date,
                c.last_update_date,
                null,
                p.claim_id,
                'PROCESSED',
                pc_lookups.get_meaning(p.service_type, 'FSA_HRA_PRODUCT_MAP')
            from
                account      acc,
                ach_transfer c,
                claimn       p
            where
                c.status in ( 1, 2 )
                and p.claim_id = c.claim_id
                and ( p.entrp_id = p_entrp_id )
                and p.takeover = 'N'
                and acc.account_type in ( 'HRA', 'FSA' )
                and acc.pers_id = p.pers_id
                and c.acc_id = acc.acc_id
                and ( acc.payroll_integration is null
                      or acc.payroll_integration = 'N' )
                and not exists (
                    select
                        *
                    from
                        employer_payment_detail ep
                    where
                            ep.transaction_id = c.transaction_id
                        and ep.transaction_source = 'PENDING_ACH'
                );

         -- INSERT PENDING CHECK DETAILS
        insert into employer_payment_detail (
            entrp_id,
            pay_amount,
            check_num,
            reason_code,
            paid_date,
            service_type,
            plan_start_date,
            plan_end_date,
            transaction_source,
            check_number,
            employer_payment_id,
            creation_date,
            last_updated_date,
            payment_notes,
            claim_id,
            status,
            change_num,
            product_type
        )
            select
                p.entrp_id,
                nvl(c.amount, 0)    pay_amount,
                'PENDING_CHECK_'
                || to_char(
                    trunc(e.check_date),
                    'MMDDYYYY'
                )                   check_num,
                reason_code,
                trunc(e.check_date) paid_date,
                p.service_type,
                p.plan_start_date,
                p.plan_end_date,
                'PENDING_CHECK'     transaction_source,
                e.check_number,
                0                   employer_payment_id,
                c.creation_date,
                c.last_updated_date,
                c.note,
                p.claim_id,
                'PROCESSED',
                c.change_num,
                pc_lookups.get_meaning(p.service_type, 'FSA_HRA_PRODUCT_MAP')
            from
                account acc,
                checks  e,
                payment c,
                claimn  p
            where
                ( p.entrp_id = p_entrp_id )
                and p.claim_id = c.claimn_id
                and p.service_type = c.plan_type
                and e.status in ( 'READY', 'SENT' )
                and p.takeover = 'N'
                and c.paid_date is null
                and e.mailed_date is null
                and acc.pers_id = p.pers_id
                and e.entity_type = 'CLAIMN'
                and e.entity_id = p.claim_id
                and e.check_amount = c.amount -- Added by Joshi for avoding duplicate records in employer_payment_details( 02/01/2024)
                and e.check_date = c.pay_date  -- Added by Joshi for avoding duplicate records in employer_payment_details( 02/01/2024)
                and acc.acc_id = e.acc_id
                and acc.account_type in ( 'HRA', 'FSA' )
                and c.acc_id = acc.acc_id
                and ( acc.payroll_integration is null
                      or acc.payroll_integration = 'N' )
                and not exists (
                    select
                        *
                    from
                        employer_payment_detail ep
                    where
                            ep.change_num = c.change_num
                        and ep.transaction_source = 'PENDING_CHECK'
                        and ep.check_number = e.check_number
                );

    end create_employer_payment_detail;

    procedure update_er_payment_detail (
        p_entrp_id in number
    ) as

        cursor l_cur is
        select
            a.entrp_id,
            sum(a.pay_amount),
            a.check_num,
            a.reason_code,
            a.paid_date,
            a.service_type,
            a.plan_start_date,
            a.plan_end_date,
            a.transaction_source,
            b.employer_payment_id,
            trunc(a.creation_date)
        from
            employer_payment_detail a,
            employer_payments       b
        where
            a.transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH' )
            and a.entrp_id = p_entrp_id
            and a.status = 'PROCESSED'
            and a.transaction_source = b.transaction_source
            and a.entrp_id = b.entrp_id
            and a.check_num = b.check_number
            and a.reason_code = b.reason_code
            and a.service_type = b.plan_type
            and a.plan_start_date = b.plan_start_date
            and a.plan_end_date = b.plan_end_date
            and a.paid_date = b.check_date
        group by
            a.entrp_id,
            a.check_num,
            a.reason_code,
            a.paid_date,
            a.service_type,
            a.plan_start_date,
            a.plan_end_date,
            a.transaction_source,
            b.check_amount,
            b.employer_payment_id,
            trunc(a.creation_date)
        having
            sum(a.pay_amount) = b.check_amount;

        cursor l_p_cur is
        select
            a.entrp_id,
            sum(a.pay_amount),
            a.check_num,
            a.reason_code,
            a.paid_date,
            a.service_type,
            a.plan_start_date,
            a.plan_end_date,
            a.transaction_source,
            b.employer_payment_id,
            trunc(a.creation_date)
        from
            employer_payment_detail a,
            employer_payments       b
        where
                a.transaction_source = 'CLAIM_PAYMENT'
            and a.employer_payment_id = 0
            and a.status = 'PROCESSED'
            and a.entrp_id = b.entrp_id
            and a.check_num = b.check_number
            and a.reason_code = b.reason_code
            and a.service_type = b.plan_type
            and a.plan_start_date = b.plan_start_date
            and a.plan_end_date = b.plan_end_date
            and a.transaction_source = b.transaction_source
            and a.paid_date = b.check_date
        group by
            a.entrp_id,
            a.check_num,
            a.reason_code,
            a.paid_date,
            a.service_type,
            a.plan_start_date,
            a.plan_end_date,
            a.transaction_source,
            b.check_amount,
            b.employer_payment_id,
            trunc(a.creation_date)
        having
            sum(a.pay_amount) = b.check_amount;

        cursor l_pc_cur is
        select
            a.entrp_id,
            sum(a.pay_amount) payment_amount,
            null              check_num,
            null              reason_code,
            null              paid_date,
            null              service_type,
            null              plan_start_date,
            null              plan_end_date,
            null              transaction_source,
            b.employer_payment_id,
            b.check_date
        from
            employer_payment_detail a,
            employer_payments       b
        where
                a.transaction_source = 'CLAIM_PAYMENT'
            and a.entrp_id = p_entrp_id
            and a.employer_payment_id = b.employer_payment_id
            and a.status in ( 'UPDATED', 'PROCESSED' )
        group by
            a.entrp_id,
            b.employer_payment_id,
            b.check_date,
            b.check_amount
        having
            sum(a.pay_amount) <> b.check_amount;

        type l_rec is record (
                entrp_id            number,
                amount              number,
                check_num           varchar2(255),
                reason_code         number,
                paid_date           date,
                service_type        varchar2(255),
                plan_start_date     date,
                plan_end_date       date,
                transaction_source  varchar2(3200),
                employer_payment_id number,
                creation_date       date
        );
        type tab is
            table of l_rec;
        l_tab      tab;
        l_pay_tab  tab;
        l_paid_tab tab;
    begin
        open l_cur;
        loop
            fetch l_cur
            bulk collect into l_tab limit 1000;
            forall i in 1..l_tab.count
                update employer_payment_detail a
                set
                    employer_payment_id = l_tab(i).employer_payment_id
                where
                        a.entrp_id = l_tab(i).entrp_id
                    and a.check_num = l_tab(i).check_num
                    and a.reason_code = l_tab(i).reason_code
                    and a.service_type = l_tab(i).service_type
                    and a.plan_start_date = l_tab(i).plan_start_date
                    and a.plan_end_date = l_tab(i).plan_end_date
                    and a.transaction_source = l_tab(i).transaction_source
                    and a.paid_date = l_tab(i).paid_date
                    and trunc(a.creation_date) = l_tab(i).creation_date;

            exit when l_tab.count < 1000;
        end loop;

        close l_cur;
        open l_p_cur;
        loop
            fetch l_p_cur
            bulk collect into l_pay_tab limit 1000;
            forall i in 1..l_pay_tab.count
                update employer_payment_detail a
                set
                    employer_payment_id = l_pay_tab(i).employer_payment_id
                where
                        a.entrp_id = l_pay_tab(i).entrp_id
                    and a.check_num = l_pay_tab(i).check_num
                    and a.reason_code = l_pay_tab(i).reason_code
                    and a.service_type = l_pay_tab(i).service_type
                    and a.plan_start_date = l_pay_tab(i).plan_start_date
                    and a.plan_end_date = l_pay_tab(i).plan_end_date
                    and a.transaction_source = l_pay_tab(i).transaction_source
                    and a.paid_date = l_pay_tab(i).paid_date
                    and trunc(a.creation_date) = l_pay_tab(i).creation_date
                    and a.employer_payment_id = 0;

            exit when l_pay_tab.count < 1000;
        end loop;

        close l_p_cur;
        open l_pc_cur;
        loop
            fetch l_pc_cur
            bulk collect into l_paid_tab limit 1000;
            forall i in 1..l_paid_tab.count
                update employer_payments a
                set
                    check_amount = l_paid_tab(i).amount
                where
                    a.employer_payment_id = l_paid_tab(i).employer_payment_id;

            exit when l_paid_tab.count < 1000;
        end loop;

        close l_pc_cur;
    end update_er_payment_detail;

    procedure activate_pop_account (
        p_entrp_id in number
    ) is
    begin
        update account
        set
            account_status = 1
         --   ,  START_DATE = SYSDATE -- COMMENTED OUT BECAUSE START DATE SHOULD NOT BE UPDATED
        where
                entrp_id = p_entrp_id
            and account_type = 'POP'
            and account_status = 3
            and exists (
                select
                    *
                from
                    employer_payments
                where
                    employer_payments.entrp_id = account.entrp_id
            );

    end activate_pop_account;
 /*   FUNCTION get_er_recon_report (p_entrp_id IN NUMBER,P_PRODUCT_TYPE IN VARCHAR2,P_END_DATE IN DATE )
 RETURN report_rcon_t PIPELINED DETERMINISTIC
 IS
   L_RECORD report_rcon_rec;
   L_BALANCE NUMBER := 0;
   L_ORD     NUMBER := 0;
 BEGIN
    FOR X IN (SELECT * FROM fsahra_er_balance_temp )
    LOOP
         L_BALANCE := L_BALANCE+X.CHECK_AMOUNT;
       L_ORD     := L_ORD+1;
       L_RECORD.transaction_type := X.transaction_type;
       L_RECORD.acc_num := X.acc_num;
       L_RECORD.claim_invoice_id := X.claim_invoice_id;
       L_RECORD.PLAN_TYPE := X.PLAN_TYPE;
       L_RECORD.TRANSACTION_DATE :=  TO_CHAR(X.TRANSACTION_DATE,'MM/DD/YYYY');
       L_RECORD.PAID_DATE := TO_CHAR(X.PAID_DATE,'MM/DD/YYYY');
       L_RECORD.FIRST_NAME := X.FIRST_NAME;
       L_RECORD.LAST_NAME := X.LAST_NAME;
       L_RECORD.BALANCE := L_BALANCE;
       L_RECORD.CHECK_AMOUNT := X.CHECK_AMOUNT;
       L_RECORD.NOTE := X.NOTE;
       L_RECORD.ORD_NO := L_ORD;
       L_RECORD.reason_code := x.reason_code;
        L_RECORD.EMPLOYER_PAYMENT_ID := x.EMPLOYER_PAYMENT_ID;

       PIPE ROW (L_RECORD);

    END LOOP;

 END get_er_recon_report;
 */

    function get_er_recon_report (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_end_date     in date
    ) return report_rcon_t
        pipelined
        deterministic
    is
        l_record  report_rcon_rec;
        l_balance number := 0;
        l_ord     number := 0;
    begin
        pc_log.log_error('get_er_recon_report', 'P_END_DATE ' || p_end_date);
        pc_log.log_error('get_er_recon_report', 'P_PRODUCT_TYPE ' || p_product_type);
        pc_log.log_error('get_er_recon_report', 'p_entrp_id ' || p_entrp_id);
        for x in (
            select
                transaction_type,
                acc_num,
                claim_invoice_id,
                check_amount,
                note,
                plan_type,
                transaction_date,
                paid_date,
                first_name,
                last_name,
                ord_no,
                reason_code,
                employer_payment_id
            from
                (

            /*    SELECT  B.FEE_NAME transaction_type,
                      '-' ACC_NUM,
                      TO_CHAR(A.INVOICE_ID) CLAIM_INVOICE_ID,
                      CHECK_AMOUNT,
                      a.note,
                      A.PLAN_TYPE,
                      TRUNC(CHECK_DATE) TRANSACTION_DATE,
                      TRUNC(CHECK_DATE) PAID_DATE,
                      '' FIRST_NAME,
                      '' LAST_NAME,
                      1 ORD_NO,
                      A.REASON_CODE,
                      a.employer_deposit_id employer_payment_id
                FROM EMPLOYER_DEPOSITS A,
                      FEE_NAMES B, ACCOUNT C
                WHERE A.ENTRP_ID= P_ENTRP_ID
                  AND   TRUNC(CHECK_DATE) <= NVL(P_END_DATE,SYSDATE)
                  AND   A.ENTRP_ID = C.ENTRP_ID
                 AND A.REASON_CODE NOT IN (5,11,12,15,8,17,18,40)
                  AND   C.ACCOUNT_TYPE IN ('HRA','FSA')
                  AND A.REASON_CODE = B.FEE_CODE
                  AND   PC_LOOKUPS.GET_meaning( A.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP') = P_PRODUCT_TYPE
                UNION ALL
                SELECT B.REASON_NAME,
                        '-' ACC_NUM,
                        TO_CHAR(A.CHECK_NUMBER),
                         -A.CHECK_amount amount ,
                        A.NOTE,
                        A.PLAN_TYPE,
                        TRUNC(A.TRANSACTION_DATE) ,
                        TRUNC(A.CHECK_DATE) ,
                        '' FIRST_NAME,
                        '' LAST_NAME,
                        2 ORD_NO,
                      A.REASON_CODE,
                      A.EMPLOYER_PAYMENT_ID
                FROM EMPLOYER_PAYMENTS A,
                     PAY_REASON B
                WHERE  A.ENTRP_ID =P_ENTRP_ID
                AND    A.REASON_CODE = B.REASON_CODE
                AND   PC_LOOKUPS.GET_meaning( A.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP') = P_PRODUCT_TYPE
                AND   TRUNC(A.CHECK_DATE) <= NVL(P_END_DATE,SYSDATE)
                AND B.REASON_CODE in  (90,25 )
                UNION ALL
                SELECT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END TRANSACTION_TYPE
                    , C.ACC_NUM , TO_CHAR(A.CLAIM_ID) , -A.PAY_AMOUNT , E.REASON_NAME , A.SERVICE_TYPE , D.PAY_DATE
                    , A.PAID_DATE , P.FIRST_NAME , P.LAST_NAME , 2 ORD_NO ,
                      A.REASON_CODE,
                      A.EMPLOYER_PAYMENT_ID
                FROM EMPLOYER_PAYMENT_DETAIL A , CLAIMN B , ACCOUNT C , PAYMENT D , PAY_REASON E , PERSON P
                WHERE a.ENTRP_ID =P_ENTRP_ID and TRANSACTION_SOURCE = 'CLAIM_PAYMENT'
                AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
                AND A.REASON_CODE <> 13
                AND TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE)
                AND A.CLAIM_ID = B.CLAIM_ID
                AND B.CLAIM_ID = D.CLAIMN_ID
                AND A.CHANGE_NUM = D.CHANGE_NUM
                AND C.ACC_ID = D.ACC_ID
                AND P.PERS_ID = B.PERS_ID
                AND B.PERS_ID = C.PERS_ID
                AND A.REASON_CODE = E.REASON_CODE
                AND A.REASON_CODE = D.REASON_CODE
                AND A.STATUS = 'PROCESSED'
                UNION ALL
                SELECT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END TRANSACTION_TYPE
                    , C.ACC_NUM , TO_CHAR(A.CLAIM_ID) , -A.PAY_AMOUNT , E.REASON_NAME , A.SERVICE_TYPE , D.PAY_DATE
                    , a.PAID_DATE , P.FIRST_NAME , P.LAST_NAME , 2 ORD_NO ,
                      A.REASON_CODE,
                      A.EMPLOYER_PAYMENT_ID
                FROM EMPLOYER_PAYMENT_DETAIL A , CLAIMN B , ACCOUNT C , PAYMENT D , PAY_REASON E , PERSON P
                   , BEN_PLAN_ENROLLMENT_SETUP BP
                WHERE a.ENTRP_ID =P_ENTRP_ID
                AND A.REASON_CODE = 13
                and TRANSACTION_SOURCE = 'CLAIM_PAYMENT'
                AND A.STATUS = 'PROCESSED'
                AND TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE)
                AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
                AND D.REASON_CODE = 13
                AND A.CLAIM_ID = B.CLAIM_ID
                AND A.CLAIM_ID = D.CLAIMN_ID
                AND A.CHANGE_NUM = D.CHANGE_NUM
                AND B.PERS_ID = C.PERS_ID
                AND C.ACC_ID = D.ACC_ID
                AND C.PERS_ID = P.PERS_ID
                AND BP.ACC_ID  = C.ACC_ID
                AND A.PRODUCT_TYPE = BP.PRODUCT_TYPE
                AND A.REASON_CODE = E.REASON_CODE
                AND BP.ENTRP_ID                = a.ENTRP_ID
                AND BP.PLAN_TYPE            =A.SERVICE_TYPE
                AND B.PLAN_END_DATE         = BP.PLAN_END_DATE
                AND B.PLAN_START_DATE       = BP.PLAN_START_DATE
                AND BP.CLAIM_REIMBURSED_BY IS NULL
               UNION ALL
                (SELECT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END TRANSACTION_TYPE
                    , C.ACC_NUM , TO_CHAR(A.CLAIM_ID) , -A.PAY_AMOUNT , E.REASON_NAME , A.SERVICE_TYPE , D.PAY_DATE
                    , a.PAID_DATE , P.FIRST_NAME , P.LAST_NAME , 2 ORD_NO ,
                      A.REASON_CODE,
                      A.EMPLOYER_PAYMENT_ID
                FROM EMPLOYER_PAYMENT_DETAIL A , CLAIMN B , ACCOUNT C , PAYMENT D , PAY_REASON E , PERSON P
                   , BEN_PLAN_ENROLLMENT_SETUP BP
                WHERE a.ENTRP_ID =P_ENTRP_ID
                AND A.REASON_CODE = 13
                and TRANSACTION_SOURCE = 'CLAIM_PAYMENT'
                AND A.STATUS = 'PROCESSED'
                AND TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE)
                AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
                AND D.REASON_CODE = 13
                AND A.CLAIM_ID = B.CLAIM_ID
                AND A.CLAIM_ID = D.CLAIMN_ID
                AND A.CHANGE_NUM = D.CHANGE_NUM
                AND B.PERS_ID = C.PERS_ID
                AND C.ACC_ID = D.ACC_ID
                AND C.PERS_ID = P.PERS_ID
                AND BP.ACC_ID  = C.ACC_ID
                AND A.PRODUCT_TYPE = BP.PRODUCT_TYPE
                AND A.REASON_CODE = E.REASON_CODE
                AND BP.ENTRP_ID                = a.ENTRP_ID
                AND BP.PLAN_TYPE            =A.SERVICE_TYPE
                AND B.PLAN_END_DATE         = BP.PLAN_END_DATE
                AND B.PLAN_START_DATE       = BP.PLAN_START_DATE
                AND BP.CLAIM_REIMBURSED_BY = 'STERLING'
                AND A.PAID_DATE            >= NVL(BP.reimburse_start_date,BP.PLAN_START_DATE)
                AND A.STATUS = 'PROCESSED'
                UNION ALL
                SELECT TRANSACTION_TYPE, ACC_NUM, CLAIM_ID,PAY_AMOUNT,REASON_NAME,SERVICE_TYPE,PAY_DATE
                        ,     PAID_DATE,FIRST_NAME,LAST_NAME,ORD_NO,REASON_CODE,EMPLOYER_PAYMENT_ID
               FROM ( SELECT DISTINCT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END TRANSACTION_TYPE
                    , C.ACC_NUM , TO_CHAR(A.CLAIM_ID) CLAIM_ID , -A.PAY_AMOUNT PAY_AMOUNT, E.REASON_NAME , A.SERVICE_TYPE , D.PAY_DATE
                    , a.PAID_DATE , P.FIRST_NAME , P.LAST_NAME , 2 ORD_NO ,
                      A.REASON_CODE,D.CHANGE_NUM,
                      A.EMPLOYER_PAYMENT_ID
                        FROM EMPLOYER_PAYMENT_DETAIL A , CLAIMN B , ACCOUNT C , PAYMENT D , PAY_REASON E , PERSON P
                           , BEN_PLAN_ENROLLMENT_SETUP BPS,BEN_PLAN_HISTORY BP
                        WHERE a.ENTRP_ID =P_ENTRP_ID and TRANSACTION_SOURCE = 'CLAIM_PAYMENT'
                       AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
                        AND A.PRODUCT_TYPE = BP.PRODUCT_TYPE
                         AND TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE)
                        AND A.CLAIM_ID = B.CLAIM_ID
                        AND A.CHANGE_NUM = D.CHANGE_NUM
                        AND B.PERS_ID = C.PERS_ID
                        AND C.ACC_ID = D.ACC_ID
                        AND A.REASON_CODE = E.REASON_CODE
                     --   AND A.REASON_CODE = D.REASON_CODE
                        AND d.REASON_CODE = 13
                        AND P.PERS_ID = B.PERS_ID
                        AND BP.PLAN_TYPE            =D.PLAN_TYPE
                        AND B.PLAN_END_DATE         = BP.PLAN_END_DATE
                        AND B.PLAN_START_DATE       = BP.PLAN_START_DATE
                        AND BP.ENTRP_ID                = a.ENTRP_ID
                        AND BP.CLAIM_REIMBURSED_BY = 'STERLING'
                        AND BPS.BEN_PLAN_ID = BP.BEN_PLAN_ID
                        AND BPS.CLAIM_REIMBURSED_BY  = 'EMPLOYER'
                        AND A.PAID_DATE BETWEEN BP.PLAN_START_DATE and NVL(BPS.reimburse_start_date,BP.PLAN_START_DATE)
                        AND A.STATUS = 'PROCESSED'))
                UNION ALL
                SELECT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END  transaction_type
                   ,   C.ACC_NUM
                   ,   TO_CHAR(A.claim_id)
                   ,  -A.PAY_AMOUNT
                   ,  CASE WHEN transaction_source = 'PENDING_CHECK' then 'Pending Check'
                                ELSE 'Pending ePayment' END
                   ,   A.SERVICE_TYPE
                   ,   A.PAID_DATE
                   ,   A.PAID_DATE
                   ,   P.FIRST_NAME
                   ,   P.LAST_NAME
                   ,    2 ORD_NO,
                      A.REASON_CODE,
                      A.EMPLOYER_PAYMENT_ID
                FROM  EMPLOYER_PAYMENT_DETAIL A
                    , CLAIMN B
                    , ACCOUNT C
                    , PAY_REASON E
                    , PERSON P
                WHERE a.ENTRP_ID =P_ENTRP_ID and TRANSACTION_SOURCE IN ('PENDING_CHECK', 'PENDING_ACH')
                AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
                and   A.STATUS = 'PROCESSED'
                AND   A.CLAIM_ID = B.CLAIM_ID
                AND   B.PERS_ID = C.PERS_ID
                 AND  A.REASON_CODE = E.REASON_CODE
                AND   P.PERS_ID = B.PERS_ID
                  AND   TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE))*/
                    select
                        b.fee_name            transaction_type,
                        '-'                   acc_num,
                        to_char(a.invoice_id) claim_invoice_id,
                        check_amount,
                        a.note,
                        a.plan_type,
                        trunc(check_date)     transaction_date,
                        trunc(check_date)     paid_date,
                        ''                    first_name,
                        ''                    last_name,
                        1                     ord_no,
                        a.reason_code,
                        a.employer_deposit_id employer_payment_id
                    from
                        employer_deposits a,
                        fee_names         b,
                        account           c
                    where
                            a.entrp_id = p_entrp_id
                        and trunc(check_date) <= nvl(p_end_date, sysdate)
                        and a.entrp_id = c.entrp_id
                        and a.reason_code not in ( 5, 11, 12, 15, 8,
                                                   17, 18, 40 )
                        and c.account_type in ( 'HRA', 'FSA' )
                        and a.reason_code = b.fee_code
                        and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    union all
                    select
                        b.reason_name,
                        '-'              acc_num,
                        to_char(a.check_number),
                        - a.check_amount amount,
                        a.note,
                        a.plan_type,
                        trunc(a.transaction_date),
                        trunc(a.check_date),
                        ''               first_name,
                        ''               last_name,
                        2                ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payments a,
                        pay_reason        b
                    where
                            a.entrp_id = p_entrp_id
                        and a.reason_code = b.reason_code
                        and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                        and trunc(a.check_date) <= nvl(p_end_date, sysdate)
                        and b.reason_code in ( 90, 25 )
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end transaction_type,
                        c.acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        e.reason_name,
                        a.service_type,
                        d.pay_date,
                        a.paid_date,
                        p.first_name,
                        p.last_name,
                        2   ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payment_detail a,
                        claimn                  b,
                        account                 c,
                        payment                 d,
                        pay_reason              e,
                        person                  p
                    where
                            a.entrp_id = p_entrp_id
                        and transaction_source = 'CLAIM_PAYMENT'
                        and a.product_type = p_product_type
                        and a.reason_code <> 13
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                        and a.claim_id = b.claim_id
                        and b.claim_id = d.claimn_id
                        and a.change_num = d.change_num
                        and c.acc_id = d.acc_id
                        and p.pers_id = b.pers_id
                        and b.pers_id = c.pers_id
                        and a.reason_code = e.reason_code
                        and a.reason_code = d.reason_code
                        and a.status = 'PROCESSED'
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end transaction_type,
                        c.acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        e.reason_name,
                        a.service_type,
                        d.pay_date,
                        a.paid_date,
                        p.first_name,
                        p.last_name,
                        2   ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payment_detail   a,
                        claimn                    b,
                        account                   c,
                        payment                   d,
                        pay_reason                e,
                        person                    p,
                        ben_plan_enrollment_setup bp
                    where
                            a.entrp_id = p_entrp_id
                        and a.reason_code = 13
                        and transaction_source = 'CLAIM_PAYMENT'
                        and a.status = 'PROCESSED'
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                        and a.product_type = p_product_type
                        and d.reason_code = 13
                        and a.claim_id = b.claim_id
                        and a.claim_id = d.claimn_id
                        and a.change_num = d.change_num
                        and b.pers_id = c.pers_id
                        and c.acc_id = d.acc_id
                        and c.pers_id = p.pers_id
                        and bp.acc_id = c.acc_id
                        and a.product_type = bp.product_type
                        and a.reason_code = e.reason_code
                        and bp.entrp_id = a.entrp_id
                        and bp.plan_type = a.service_type
                        and b.plan_end_date = bp.plan_end_date
                        and b.plan_start_date = bp.plan_start_date
                        and bp.claim_reimbursed_by is null
                    union all
                    (
                        select
                            case
                                when a.reason_code in ( 11, 12, 13, 19 ) then
                                    'Claim Payment'
                                else
                                    reason_name
                            end transaction_type,
                            c.acc_num,
                            to_char(a.claim_id),
                            - a.pay_amount,
                            e.reason_name,
                            a.service_type,
                            d.pay_date,
                            a.paid_date,
                            p.first_name,
                            p.last_name,
                            2   ord_no,
                            a.reason_code,
                            a.employer_payment_id
                        from
                            employer_payment_detail   a,
                            claimn                    b,
                            account                   c,
                            payment                   d,
                            pay_reason                e,
                            person                    p,
                            ben_plan_enrollment_setup bp
                        where
                                a.entrp_id = p_entrp_id
                            and a.reason_code = 13
                            and transaction_source = 'CLAIM_PAYMENT'
                            and a.status = 'PROCESSED'
                            and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                            and a.product_type = p_product_type
                            and d.reason_code = 13
                            and a.claim_id = b.claim_id
                            and a.claim_id = d.claimn_id
                            and a.change_num = d.change_num
                            and b.pers_id = c.pers_id
                            and c.acc_id = d.acc_id
                            and c.pers_id = p.pers_id
                            and bp.acc_id = c.acc_id
                            and a.product_type = bp.product_type
                            and a.reason_code = e.reason_code
                --AND BP.ENTRP_ID                = a.ENTRP_ID  -- COmmented by Swamy for Ticket#11027 on 01/04/2022
                            and bp.plan_type = a.service_type
                            and b.plan_end_date = bp.plan_end_date
                            and b.plan_start_date = bp.plan_start_date
                            and bp.claim_reimbursed_by = 'STERLING'
                            and a.paid_date >= nvl(bp.reimburse_start_date, bp.plan_start_date)
                            and a.status = 'PROCESSED'
                        union all
                        select
                            transaction_type,
                            acc_num,
                            claim_id,
                            pay_amount,
                            reason_name,
                            service_type,
                            pay_date,
                            paid_date,
                            first_name,
                            last_name,
                            ord_no,
                            reason_code,
                            employer_payment_id
                        from
                            (
                                select distinct
                                    case
                                        when a.reason_code in ( 11, 12, 13, 19 ) then
                                            'Claim Payment'
                                        else
                                            reason_name
                                    end                 transaction_type,
                                    c.acc_num,
                                    to_char(a.claim_id) claim_id,
                                    - a.pay_amount      pay_amount,
                                    e.reason_name,
                                    a.service_type,
                                    d.pay_date,
                                    a.paid_date,
                                    p.first_name,
                                    p.last_name,
                                    2                   ord_no,
                                    a.reason_code,
                                    d.change_num,
                                    a.employer_payment_id
                                from
                                    employer_payment_detail   a,
                                    claimn                    b,
                                    account                   c,
                                    payment                   d,
                                    pay_reason                e,
                                    person                    p,
                                    ben_plan_enrollment_setup bps,
                                    ben_plan_history          bp
                                where
                                        a.entrp_id = p_entrp_id
                                    and a.reason_code = 13
                                    and transaction_source = 'CLAIM_PAYMENT'
                                    and a.status = 'PROCESSED'
                                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                                    and a.product_type = p_product_type
                                    and d.reason_code = 13
                                    and a.claim_id = b.claim_id
                                    and a.claim_id = d.claimn_id
                                    and a.change_num = d.change_num
                                    and b.pers_id = c.pers_id
                                    and c.acc_id = d.acc_id
                                    and c.pers_id = p.pers_id
                                    and bp.acc_id = c.acc_id
                                    and a.product_type = bp.product_type
                                    and a.reason_code = e.reason_code
                                    and bp.entrp_id = a.entrp_id
                                    and b.plan_end_date = bp.plan_end_date
                                    and b.plan_start_date = bp.plan_start_date
                                    and bp.entrp_id = a.entrp_id
                                    and bp.claim_reimbursed_by = 'STERLING'
                                    and bps.ben_plan_id = bp.ben_plan_id
                                    and bps.claim_reimbursed_by = 'EMPLOYER'
                                    and a.paid_date between bp.plan_start_date and nvl(bps.reimburse_start_date, bp.plan_start_date)
                                    and a.status = 'PROCESSED'
                            )
                    )
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end transaction_type,
                        c.acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        case
                            when transaction_source = 'PENDING_CHECK' then
                                'Pending Check'
                            else
                                'Pending ePayment'
                        end,
                        a.service_type,
                        a.paid_date,
                        a.paid_date,
                        p.first_name,
                        p.last_name,
                        2   ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payment_detail a,
                        claimn                  b,
                        account                 c,
                        pay_reason              e,
                        person                  p
                    where
                            a.entrp_id = p_entrp_id
                        and transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH' )
                        and a.product_type = p_product_type
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                        and a.status = 'PROCESSED'
                        and a.claim_id = b.claim_id
                        and p.pers_id = b.pers_id
                        and b.pers_id = c.pers_id
                        and a.reason_code = e.reason_code
                )
            order by
                paid_date asc,
                ord_no asc
        ) loop
            l_balance := l_balance + x.check_amount;
            l_ord := l_ord + 1;
            l_record.transaction_type := x.transaction_type;
            l_record.acc_num := x.acc_num;
            l_record.claim_invoice_id := x.claim_invoice_id;
            l_record.plan_type := x.plan_type;
            l_record.transaction_date := to_char(x.transaction_date, 'MM/DD/YYYY');
            l_record.paid_date := to_char(x.paid_date, 'MM/DD/YYYY');
            l_record.first_name := x.first_name;
            l_record.last_name := x.last_name;
            l_record.balance := l_balance;
            l_record.check_amount := x.check_amount;
            l_record.note := x.note;
            l_record.ord_no := l_ord;
            l_record.reason_code := x.reason_code;
            l_record.employer_payment_id := x.employer_payment_id;
            pipe row ( l_record );
        end loop;

    end get_er_recon_report;

    function get_er_balance_report (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_end_date     in date
    ) return report_rcon_t
        pipelined
        deterministic
    is

        l_record       report_rcon_rec;
        l_balance      number := 0;
        l_ord          number := 0;
        l_check_amount number := 0;
    begin
        for x in (
            select
                sum(check_amount) balance,
                max(paid_date)    paid_date
            from
                (
                    select
                        b.fee_name            transaction_type,
                        '-'                   acc_num,
                        to_char(a.invoice_id) claim_invoice_id,
                        check_amount,
                        a.note,
                        a.plan_type,
                        trunc(check_date)     transaction_date,
                        trunc(check_date)     paid_date,
                        ''                    first_name,
                        ''                    last_name,
                        1                     ord_no,
                        a.reason_code,
                        a.employer_deposit_id employer_payment_id
                    from
                        employer_deposits a,
                        fee_names         b,
                        account           c
                    where
                            a.entrp_id = p_entrp_id
                        and a.reason_code = b.fee_code
                        and a.entrp_id = c.entrp_id
                        and c.account_type in ( 'HRA', 'FSA' )
                        and trunc(check_date) <= nvl(p_end_date, sysdate)
                        and a.reason_code not in ( 5, 11, 12, 15, 8,
                                                   17, 18, 40 )
                        and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    union all
                    select
                        b.reason_name,
                        '-'              acc_num,
                        to_char(a.check_number),
                        - a.check_amount amount,
                        a.note,
                        a.plan_type,
                        trunc(a.transaction_date),
                        trunc(a.check_date),
                        ''               first_name,
                        ''               last_name,
                        2                ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payments a,
                        pay_reason        b
                    where
                            a.entrp_id = p_entrp_id
                        and a.reason_code = b.reason_code
                        and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                        and trunc(a.check_date) <= nvl(p_end_date, sysdate)
                        and b.reason_code = 25
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end transaction_type,
                        c.acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        e.reason_name,
                        a.service_type,
                        d.pay_date,
                        a.paid_date,
                        p.first_name,
                        p.last_name,
                        2   ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payment_detail a,
                        claimn                  b,
                        account                 c,
                        payment                 d,
                        pay_reason              e,
                        person                  p
                    where
                            a.entrp_id = p_entrp_id
                        and transaction_source = 'CLAIM_PAYMENT'
                        and a.product_type = p_product_type
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                        and a.claim_id = b.claim_id
                        and a.change_num = d.change_num
                        and b.pers_id = c.pers_id
                        and c.acc_id = d.acc_id
                        and a.reason_code = e.reason_code
                        and a.reason_code = d.reason_code
                        and a.reason_code <> 13
                        and p.pers_id = b.pers_id
                        and a.status = 'PROCESSED'
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end transaction_type,
                        c.acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        e.reason_name,
                        a.service_type,
                        d.pay_date,
                        a.paid_date,
                        p.first_name,
                        p.last_name,
                        2   ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payment_detail   a,
                        claimn                    b,
                        account                   c,
                        payment                   d,
                        pay_reason                e,
                        person                    p,
                        ben_plan_enrollment_setup bp
                    where
                            a.entrp_id = p_entrp_id
                        and transaction_source = 'CLAIM_PAYMENT'
                        and a.product_type = p_product_type
                        and a.product_type = bp.product_type
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                        and a.claim_id = b.claim_id
                        and a.change_num = d.change_num
                        and b.pers_id = c.pers_id
                        and c.acc_id = d.acc_id
                        and a.reason_code = e.reason_code
                        and a.reason_code = d.reason_code
                        and a.reason_code = 13
                        and p.pers_id = b.pers_id
                        and bp.plan_type = a.service_type
                        and b.plan_end_date = bp.plan_end_date
                        and b.plan_start_date = bp.plan_start_date
                        and bp.acc_id = c.acc_id
                        and bp.claim_reimbursed_by is null
                        and a.status = 'PROCESSED'
                    union all
                    (
                        select
                            case
                                when a.reason_code in ( 11, 12, 13, 19 ) then
                                    'Claim Payment'
                                else
                                    reason_name
                            end transaction_type,
                            c.acc_num,
                            to_char(a.claim_id),
                            - a.pay_amount,
                            e.reason_name,
                            a.service_type,
                            d.pay_date,
                            a.paid_date,
                            p.first_name,
                            p.last_name,
                            2   ord_no,
                            a.reason_code,
                            a.employer_payment_id
                        from
                            employer_payment_detail   a,
                            claimn                    b,
                            account                   c,
                            payment                   d,
                            pay_reason                e,
                            person                    p,
                            ben_plan_enrollment_setup bp
                        where
                                a.entrp_id = p_entrp_id
                            and transaction_source = 'CLAIM_PAYMENT'
                            and a.product_type = p_product_type
                            and a.product_type = bp.product_type
                            and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                            and a.claim_id = b.claim_id
                            and a.change_num = d.change_num
                            and b.pers_id = c.pers_id
                            and c.acc_id = d.acc_id
                            and a.reason_code = e.reason_code
                            and a.reason_code = d.reason_code
                            and a.reason_code = 13
                            and p.pers_id = b.pers_id
                            and bp.plan_type = d.plan_type
                            and b.plan_end_date = bp.plan_end_date
                            and b.plan_start_date = bp.plan_start_date
                            and bp.entrp_id = a.entrp_id
                            and bp.claim_reimbursed_by = 'STERLING'
                            and a.paid_date >= nvl(bp.reimburse_start_date, bp.plan_start_date)
                            and a.status = 'PROCESSED'
                        union
                        select
                            case
                                when a.reason_code in ( 11, 12, 13, 19 ) then
                                    'Claim Payment'
                                else
                                    reason_name
                            end transaction_type,
                            c.acc_num,
                            to_char(a.claim_id),
                            - a.pay_amount,
                            e.reason_name,
                            a.service_type,
                            d.pay_date,
                            a.paid_date,
                            p.first_name,
                            p.last_name,
                            2   ord_no,
                            a.reason_code,
                            a.employer_payment_id
                        from
                            employer_payment_detail a,
                            claimn                  b,
                            account                 c,
                            payment                 d,
                            pay_reason              e,
                            person                  p,
                            (
                                select distinct
                                    bp.entrp_id,
                                    bp.plan_type,
                                    bp.plan_end_date,
                                    bp.plan_start_date,
                                    bps.reimburse_start_date,
                                    bp.product_type
                                from
                                    ben_plan_enrollment_setup bps,
                                    ben_plan_history          bp
                                where
                                        bp.entrp_id = p_entrp_id
                                    and bp.claim_reimbursed_by = 'STERLING'
                                    and bps.ben_plan_id = bp.ben_plan_id
                                    and bps.claim_reimbursed_by = 'EMPLOYER'
                            )                       bp
                        where
                                a.entrp_id = p_entrp_id
                            and transaction_source = 'CLAIM_PAYMENT'
                            and a.product_type = p_product_type
                            and a.product_type = bp.product_type
                            and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                            and a.claim_id = b.claim_id
                            and a.change_num = d.change_num
                            and b.pers_id = c.pers_id
                            and c.acc_id = d.acc_id
                            and a.reason_code = e.reason_code
                            and a.reason_code = d.reason_code
                            and a.reason_code = 13
                            and p.pers_id = b.pers_id
                            and bp.plan_type = d.plan_type
                            and b.plan_end_date = bp.plan_end_date
                            and b.plan_start_date = bp.plan_start_date
                            and bp.entrp_id = a.entrp_id
                            and a.paid_date between bp.plan_start_date and nvl(bp.reimburse_start_date, bp.plan_start_date)
                            and a.status = 'PROCESSED'
               /* SELECT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END TRANSACTION_TYPE
                    , C.ACC_NUM , TO_CHAR(A.CLAIM_ID) , -A.PAY_AMOUNT , E.REASON_NAME , A.SERVICE_TYPE , D.PAY_DATE
                    , a.PAID_DATE , P.FIRST_NAME , P.LAST_NAME , 2 ORD_NO ,
                      A.REASON_CODE,
                      A.EMPLOYER_PAYMENT_ID
                FROM EMPLOYER_PAYMENT_DETAIL A , CLAIMN B , ACCOUNT C , PAYMENT D , PAY_REASON E , PERSON P
                   , BEN_PLAN_ENROLLMENT_SETUP BPS,BEN_PLAN_HISTORY BP
                WHERE a.ENTRP_ID =P_ENTRP_ID and TRANSACTION_SOURCE = 'CLAIM_PAYMENT'
               AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
                AND A.PRODUCT_TYPE = BP.PRODUCT_TYPE
                 AND TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE)
                AND A.CLAIM_ID = B.CLAIM_ID
                AND A.CHANGE_NUM = D.CHANGE_NUM
                AND B.PERS_ID = C.PERS_ID
                AND C.ACC_ID = D.ACC_ID
                AND A.REASON_CODE = E.REASON_CODE
                AND A.REASON_CODE = D.REASON_CODE
                AND A.REASON_CODE = 13
                AND P.PERS_ID = B.PERS_ID
                AND BP.PLAN_TYPE            =D.PLAN_TYPE
                AND B.PLAN_END_DATE         = BP.PLAN_END_DATE
                AND B.PLAN_START_DATE       = BP.PLAN_START_DATE
                AND BP.ENTRP_ID                = a.ENTRP_ID
                AND BP.CLAIM_REIMBURSED_BY = 'STERLING'
                AND BPS.BEN_PLAN_ID = BP.BEN_PLAN_ID
                AND BPS.CLAIM_REIMBURSED_BY  = 'EMPLOYER'
                AND A.PAID_DATE BETWEEN BP.PLAN_START_DATE and NVL(BPS.reimburse_start_date,BP.PLAN_START_DATE)
                AND A.STATUS = 'PROCESSED'*/
                    )
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end transaction_type,
                        c.acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        'Pending ePayment',
                        a.service_type,
                        a.paid_date,
                        a.paid_date,
                        p.first_name,
                        p.last_name,
                        2   ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payment_detail a,
                        claimn                  b,
                        account                 c,
                        pay_reason              e,
                        person                  p
                    where
                            a.entrp_id = p_entrp_id
                        and transaction_source = 'PENDING_ACH'
                        and a.product_type = p_product_type
                        and a.status = 'PROCESSED'
                        and a.claim_id = b.claim_id
                        and b.pers_id = c.pers_id
                        and a.reason_code = e.reason_code
                        and p.pers_id = b.pers_id
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end transaction_type,
                        c.acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        'Pending Check',
                        a.service_type,
                        a.paid_date,
                        a.paid_date,
                        p.first_name,
                        p.last_name,
                        2   ord_no,
                        a.reason_code,
                        a.employer_payment_id
                    from
                        employer_payment_detail a,
                        claimn                  b,
                        account                 c,
                        pay_reason              e,
                        person                  p
                    where
                            a.entrp_id = p_entrp_id
                        and transaction_source = 'PENDING_CHECK'
                        and a.product_type = p_product_type
                        and a.status = 'PROCESSED'
                        and a.claim_id = b.claim_id
                        and b.pers_id = c.pers_id
                        and a.reason_code = e.reason_code
                        and p.pers_id = b.pers_id
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                )
        ) loop
            l_balance := x.balance;
            l_record.paid_date := x.paid_date;
        end loop;

        l_record.balance := l_balance;
        pipe row ( l_record );
    end get_er_balance_report;

    function get_funding_er_balance return employer_balance_t
        pipelined
        deterministic
    is
        l_record employer_balance_rec;
    begin
        for x in (
            select distinct
                b.acc_num,
                a.entrp_id,
                a.product_type
                  --a.claim_reimbursed_by, a.funding_options
            from
                ben_plan_enrollment_setup a,
                account                   b
            where
                a.entrp_id is not null
                and b.account_type in ( 'HRA', 'FSA' )
               -- AND     a.plan_end_date>=sysdate /*sk commented on jessica's request 02/01/2023*/
                and a.product_type in ( 'HRA', 'FSA' )
                and a.entrp_id = b.entrp_id
               -- AND     b.account_status=1
                and a.funding_options is not null
                and a.funding_options != '-1'
        ) loop
            l_record.acc_num := x.acc_num;
            l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
            l_record.css := pc_sales_team.get_cust_srvc_rep_name_for_er(x.entrp_id);
        --L_RECORD.funding_options := X.funding_options;
        --L_RECORD.CLAIM_REIMBURSED_BY := X.CLAIM_REIMBURSED_BY;
            l_record.er_balance := pc_employer_fin.get_employer_balance(x.entrp_id, sysdate, x.product_type);

            l_record.product_type := x.product_type;
            pipe row ( l_record );
        end loop;
    end get_funding_er_balance;

    function get_er_recon_report1 (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_end_date     in date
    ) return report_rcon_t
        pipelined
        deterministic
    is
        l_record  report_rcon_rec;
        l_balance number := 0;
        l_ord     number := 0;
    begin
        pc_log.log_error('get_er_recon_report', 'P_END_DATE ' || p_end_date);
        pc_log.log_error('get_er_recon_report', 'P_PRODUCT_TYPE ' || p_product_type);
        pc_log.log_error('get_er_recon_report', 'p_entrp_id ' || p_entrp_id);
        for x in (
            select
                transaction_type,
                acc_num,
                claim_invoice_id,
                check_amount,
                note,
                plan_type,
                transaction_date,
                paid_date,
                first_name,
                last_name,
                ord_no,
                reason_code,
                employer_payment_id,
                claim_id,
                change_num,
                entrp_id
            from
                (
                    select
                        b.fee_name            transaction_type,
                        '-'                   acc_num,
                        to_char(a.invoice_id) claim_invoice_id,
                        check_amount,
                        a.note,
                        a.plan_type,
                        trunc(check_date)     transaction_date,
                        trunc(check_date)     paid_date,
                        ''                    first_name,
                        ''                    last_name,
                        1                     ord_no,
                        a.reason_code,
                        a.employer_deposit_id employer_payment_id,
                        null                  claim_id,
                        null                  change_num,
                        a.entrp_id
                    from
                        employer_deposits a,
                        fee_names         b,
                        account           c
                    where
                            a.entrp_id = p_entrp_id
                        and a.reason_code = b.fee_code
                        and a.entrp_id = c.entrp_id
                        and c.account_type in ( 'HRA', 'FSA' )
                        and trunc(check_date) <= nvl(p_end_date, sysdate)
                        and a.reason_code not in ( 5, 11, 12, 15, 8,
                                                   17, 18, 40 )
                        and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    union all
                    select
                        b.reason_name,
                        '-'              acc_num,
                        to_char(a.check_number),
                        - a.check_amount amount,
                        a.note,
                        a.plan_type,
                        trunc(a.transaction_date),
                        trunc(a.check_date),
                        ''               first_name,
                        ''               last_name,
                        2                ord_no,
                        a.reason_code,
                        a.employer_payment_id,
                        null             claim_id,
                        null             change_num,
                        a.entrp_id
                    from
                        employer_payments a,
                        pay_reason        b
                    where
                            a.entrp_id = p_entrp_id
                        and a.reason_code = b.reason_code
                        and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                        and trunc(a.check_date) <= nvl(p_end_date, sysdate)
                        and b.reason_code = 25
                    union all
                    select
                        case
                            when a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            else
                                reason_name
                        end  transaction_type,
                        null acc_num,
                        to_char(a.claim_id),
                        - a.pay_amount,
                        case
                            when transaction_source not in ( 'PENDING_ACH', 'PENDING_CHECK' )
                                 and a.reason_code in ( 11, 12, 13, 19 ) then
                                'Claim Payment'
                            when transaction_source = 'PENDING_ACH'   then
                                'Pending ACH'
                            when transaction_source = 'PENDING_CHECK' then
                                'Pending Check'
                            else
                                e.reason_name
                        end  reason_name,
                        a.service_type,
                        null pay_date,
                        a.paid_date,
                        null first_name,
                        null last_name,
                        2    ord_no,
                        a.reason_code,
                        a.employer_payment_id,
                        a.claim_id,
                        a.change_num,
                        a.entrp_id
                    from
                        employer_payment_detail a,
                        pay_reason              e
                    where
                            a.entrp_id = p_entrp_id
                        and transaction_source in ( 'CLAIM_PAYMENT', 'PENDING_ACH', 'PENDING_CHECK' )
                        and a.product_type = p_product_type
                        and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                        and a.status = 'PROCESSED'
                )
            order by
                paid_date asc,
                ord_no asc
        ) loop
            l_record.transaction_date := to_char(x.transaction_date, 'MM/DD/YYYY');
            if
                x.ord_no = 2
                and x.change_num is not null
                and x.reason_code <> 13
            then
                for xx in (
                    select
                        pay_date
                    from
                        payment
                    where
                        change_num = x.change_num
                ) loop
                    l_balance := l_balance + x.check_amount;
                    l_ord := l_ord + 1;
                    l_record.transaction_date := to_char(xx.pay_date, 'MM/DD/YYYY');
                end loop;

            end if;

            if
                x.ord_no = 2
                and x.change_num is not null
                and x.reason_code = 13
            then
                for xx in (
                    select
                        pay_date,
                        bp.claim_reimbursed_by,
                        bp.reimburse_start_date,
                        bp.plan_start_date,
                        p.paid_date
                    from
                        claimn                    a,
                        payment                   p,
                        ben_plan_enrollment_setup bp
                    where
                            p.change_num = x.change_num
                        and p.claimn_id = a.claim_id
                        and bp.entrp_id = x.entrp_id
                        and a.plan_end_date = bp.plan_end_date
                        and a.plan_start_date = bp.plan_start_date
                        and bp.plan_type = a.service_type
                        and a.service_type = x.plan_type
                        and nvl(bp.claim_reimbursed_by, 'STERLING') = 'STERLING'
                        and p.paid_date >= nvl(bp.reimburse_start_date, bp.plan_start_date)
                ) loop
                    if xx.claim_reimbursed_by = 'STERLING' then
                        l_balance := l_balance + x.check_amount;
                        l_ord := l_ord + 1;
                        l_record.transaction_date := to_char(xx.pay_date, 'MM/DD/YYYY');
                    end if;
                end loop;
         /*    FOR XX IN ( SELECT PAY_DATE,BP.CLAIM_REIMBURSED_BY, BPS.reimburse_start_date
	                     , BP.PLAN_START_DATE, P.PAID_DATE
	                  FROM  CLAIMN A, PAYMENT P
                              , BEN_PLAN_ENROLLMENT_SETUP BP
	             		      , BEN_PLAN_HISTORY BPS
	             		 WHERE  P.CHANGE_NUM = X.CHANGE_NUM
	            		 AND    P.CLAIMN_ID = A.CLAIM_ID
                         AND    A.PLAN_END_DATE         = BP.PLAN_END_DATE
                         AND    A.PLAN_START_DATE       = BP.PLAN_START_DATE
                         AND    BP.PLAN_TYPE            =A.SERVICE_TYPE
	            		 AND    A.SERVICE_TYPE         = X.PLAN_TYPE
	            		 AND    BPS.BEN_PLAN_ID        = BP.BEN_PLAN_ID
                   AND    BPS.CLAIM_REIMBURSED_BY  <> BP.CLAIM_REIMBURSED_BY
	            		 AND    NVL(BP.CLAIM_REIMBURSED_BY,'STERLING' ) = 'STERLING'
		              	 AND    P.PAID_DATE BETWEEN BP.PLAN_START_DATE and NVL(BPS.reimburse_start_date,BP.PLAN_START_DATE)
		         	 )
             LOOP
               IF     XX.CLAIM_REIMBURSED_BY = 'STERLING'
		           AND    X.PAID_DATE >= NVL(XX.reimburse_start_date,XX.PLAN_START_DATE) THEN
			                L_BALANCE := L_BALANCE+X.CHECK_AMOUNT;
		         	       L_ORD     := L_ORD+1;
		       	       L_RECORD.TRANSACTION_DATE :=  TO_CHAR(XX.PAY_DATE,'MM/DD/YYYY');
                 END IF;
  	        END LOOP;*/

            end if;

            l_record.transaction_type := x.transaction_type;
            l_record.claim_invoice_id := x.claim_invoice_id;
            l_record.plan_type := x.plan_type;
            l_record.paid_date := to_char(x.paid_date, 'MM/DD/YYYY');
            for xx in (
                select
                    a.acc_num,
                    p.first_name,
                    p.last_name
                from
                    claimn  c,
                    person  p,
                    account a
                where
                        c.claim_id = x.claim_invoice_id
                    and c.pers_id = p.pers_id
                    and a.pers_id = p.pers_id
            ) loop
                l_record.acc_num := xx.acc_num;
                l_record.first_name := xx.first_name;
                l_record.last_name := xx.last_name;
            end loop;

            l_record.balance := l_balance;
            l_record.check_amount := x.check_amount;
            l_record.note := x.note;
            l_record.ord_no := l_ord;
            l_record.reason_code := x.reason_code;
            l_record.employer_payment_id := x.employer_payment_id;
            pipe row ( l_record );
        end loop;

    end get_er_recon_report1;

    function get_funding_er_balance_by_date (
        p_end_date in date
    ) return employer_balance_t
        pipelined
        deterministic
    is
        l_record employer_balance_rec;
    begin
        for x in (
            select distinct
                b.acc_num,
                a.entrp_id,
                a.product_type
                  --a.claim_reimbursed_by, a.funding_options
            from
                ben_plan_enrollment_setup a,
                account                   b
            where
                a.entrp_id is not null
                and b.account_type in ( 'HRA', 'FSA' )
               -- AND     a.plan_end_date>=sysdate /*sk commented on jessica's request 02/01/2023*/
                and a.product_type in ( 'HRA', 'FSA' )
                and a.entrp_id = b.entrp_id
               -- AND     b.account_status=1
                and a.funding_options is not null
                and a.funding_options != '-1'
        ) loop
            l_record.acc_num := x.acc_num;
            l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
            l_record.css := pc_sales_team.get_cust_srvc_rep_name_for_er(x.entrp_id);
        --L_RECORD.funding_options := X.funding_options;
        --L_RECORD.CLAIM_REIMBURSED_BY := X.CLAIM_REIMBURSED_BY;
            l_record.er_balance := pc_employer_fin.get_employer_balance(x.entrp_id, p_end_date, x.product_type);

            l_record.product_type := x.product_type;
            pipe row ( l_record );
        end loop;
    end get_funding_er_balance_by_date;

end pc_employer_fin;
/


-- sqlcl_snapshot {"hash":"34b357237a9447442bd7759a3e063d29dd98b339","type":"PACKAGE_BODY","name":"PC_EMPLOYER_FIN","schemaName":"SAMQA","sxml":""}