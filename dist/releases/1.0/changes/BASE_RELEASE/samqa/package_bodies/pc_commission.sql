-- liquibase formatted sql
-- changeset SAMQA:1754373989221 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_commission.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_commission.sql:null:083b4a4a999c796a9f0d7956f2ab46e9de1cfe2c:create

create or replace package body samqa.pc_commission as

    p_effective_date date := '01-JAN-2018';

    function get_ytd_revenue (
        p_account_type in varchar2,
        p_end_date     in date,
        p_reason_code  in number
    ) return number is
        l_check_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.check_amount, 0)) check_amount
            from
                employer_payments a,
                account           b
            where
                    a.entrp_id = b.entrp_id
                and a.plan_type = p_account_type
                and a.reason_code = p_reason_code
                and ( a.transaction_source is null
                      or a.transaction_source = 'PAYMENT' )
                and a.check_date between trunc(sysdate, 'YYYY') and nvl(p_end_date, sysdate)
        ) loop
            l_check_amount := x.check_amount;
        end loop;

        return l_check_amount;
    end get_ytd_revenue;

    function get_revenue (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number
    ) return number is
        l_check_amount number := 0;
    begin
        for x in (
            select
                sum(check_amount) check_amount
            from
                (
                    select
                        sum(nvl(a.check_amount, 0)) check_amount
                    from
                        employer_payments a,
                        account           b
                    where
                            a.entrp_id = b.entrp_id
                        and p_account_type in ( 'HRA', 'FSA' )
                        and a.plan_type = p_account_type
                        and ( a.transaction_source is null
                              or a.transaction_source = 'PAYMENT' )
                        and a.reason_code = 1
                        and p_reason_code = 1
                        and a.check_date between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history c
                            where
                                    c.entrp_id = b.entrp_id
                                and c.pers_id is not null
                        )
                        and exists (
                            select
                                *
                            from
                                person
                            where
                                entrp_id = b.entrp_id
                        )
                    union all
                    select
                        sum(nvl(a.check_amount, 0)) check_amount
                    from
                        employer_payments a,
                        account           b
                    where
                            a.entrp_id = b.entrp_id
                        and p_account_type in ( 'HRA', 'FSA' )
                        and a.plan_type = p_account_type
                        and ( a.transaction_source is null
                              or a.transaction_source = 'PAYMENT' )
                        and a.reason_code = 30
                        and p_reason_code = 30
                        and a.check_date between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history c
                            where
                                    c.entrp_id = b.entrp_id
                                and a.transaction_date between c.plan_start_date and c.plan_end_date
                                and fee_paid > 0
                        )
                        and exists (
                            select
                                *
                            from
                                person                    d,
                                account                   e,
                                ben_plan_enrollment_setup f
                            where
                                    d.entrp_id = b.entrp_id
                                and e.pers_id = d.pers_id
                                and f.status in ( 'A', 'I' )
                                and f.acc_id = e.acc_id
                                and a.transaction_date between f.plan_start_date and f.plan_end_date
                        )
                    union all
                    select
                        sum(nvl(a.check_amount, 0)) check_amount
                    from
                        employer_payments a,
                        account           b
                    where
                            a.entrp_id = b.entrp_id
                        and ( p_account_type not in ( 'HRA', 'FSA' )
                              and b.account_type = p_account_type )
                        and ( a.transaction_source is null
                              or a.transaction_source = 'PAYMENT' )
                        and a.reason_code = case
                                                when p_reason_code = 100 then
                                                    30
                                                else
                                                    p_reason_code
                                            end
                        and a.check_date between p_start_date and p_end_date
                )
        ) loop
            l_check_amount := x.check_amount;
        end loop;

        return nvl(l_check_amount, 0);
    end get_revenue;

    function get_sales_revenue (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number,
        p_entrp_id     in number
    ) return number is
        l_check_amount number := 0;
    begin
        for x in (
            select
                sum(check_amount) check_amount
            from
                (
                    select
                        sum(nvl(a.check_amount, 0)) check_amount
                    from
                        employer_payments a,
                        account           b
                    where
                            a.entrp_id = p_entrp_id
                        and a.entrp_id = b.entrp_id
                        and p_account_type in ( 'HRA', 'FSA' )
                        and a.plan_type = p_account_type
                        and ( a.transaction_source is null
                              or a.transaction_source = 'PAYMENT' )
                        and a.reason_code = 1
                        and p_reason_code = 1
                        and a.transaction_date between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history c
                            where
                                    c.entrp_id = b.entrp_id
                                and c.pers_id is null
                                and account_type = c.account_type
                        )
                    union all
                    select
                        sum(nvl(a.check_amount, 0)) check_amount
                    from
                        employer_payments a,
                        account           b
                    where
                            a.entrp_id = p_entrp_id
                        and a.entrp_id = b.entrp_id
                        and p_account_type in ( 'HRA', 'FSA' )
                        and a.plan_type = p_account_type
                        and ( a.transaction_source is null
                              or a.transaction_source = 'PAYMENT' )
                        and a.reason_code = 30
                        and p_reason_code = 30
                        and a.transaction_date between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history c
                            where
                                    c.entrp_id = b.entrp_id
                                and c.pers_id is null
                                and account_type = c.account_type
                                and c.renewal_date < a.transaction_date
                                and fee_paid > 0
                        )
                    union all
                    select
                        sum(nvl(a.check_amount, 0)) check_amount
                    from
                        employer_payments a,
                        account           b
                    where
                            a.entrp_id = p_entrp_id
                        and a.entrp_id = b.entrp_id
                        and ( p_account_type not in ( 'HRA', 'FSA' )
                              and b.account_type = p_account_type )
                        and ( a.transaction_source is null
                              or a.transaction_source = 'PAYMENT' )
                        and a.reason_code = case
                                                when p_reason_code = 100 then
                                                    30
                                                else
                                                    p_reason_code
                                            end
                        and a.check_date between p_start_date and p_end_date
                )
        ) loop
            l_check_amount := x.check_amount;
        end loop;

        return nvl(l_check_amount, 0);
    end get_sales_revenue;

    function get_total_account (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number
    ) return number is
        l_no_of_accounts number := 0;
    begin
        if p_reason_code = 1 then
            select
                count(distinct acc_num) no_of_accounts
            into l_no_of_accounts
            from
                table ( pc_commission.get_summary_salesrep_report(p_account_type, p_start_date, p_end_date) )
            where
                renewal = 'N';

        end if;

        if
            p_reason_code = 30
            and p_account_type in ( 'HRA', 'FSA' )
        then
            select
                count(distinct acc_num) no_of_accounts
            into l_no_of_accounts
            from
                table ( pc_commission.get_summary_salesrep_report(p_account_type, p_start_date, p_end_date) )
            where
                renewal = 'Y';

        end if;

        if
            p_reason_code in ( 30, 100 )
            and p_account_type not in ( 'HRA', 'FSA' )
        then
            select
                count(distinct acc_num) no_of_accounts
            into l_no_of_accounts
            from
                table ( pc_commission.get_summary_salesrep_report(p_account_type, p_start_date, p_end_date) )
            where
                renewal = 'Y';

        end if;

        return l_no_of_accounts;
    end get_total_account;

    function get_revenue_per_account (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number
    ) return number is
        l_no_of_accounts number := 0;
        l_revenue        number := 0;
        l_rev_per_acct   number := 0;
    begin
        l_no_of_accounts := get_total_account(p_account_type, p_start_date, p_end_date, p_reason_code);
        l_revenue := get_revenue(p_account_type, p_start_date, p_end_date, p_reason_code);
        if l_no_of_accounts > 0 then
            l_rev_per_acct := l_revenue / l_no_of_accounts;
        end if;
        return l_rev_per_acct;
    end get_revenue_per_account;

    function get_summary_enrolled_report (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return enrolled_row_t
        pipelined
        deterministic
    is
        l_record   enrolled_row;
        l_entrp_id number := 0;
    begin
        if p_account_type in ( 'FORM_5500', 'CMP' ) then --Removed POP from this on 09/30/2018
            for x in (
                select
                    a.salesrep_id,
                    a.acc_num,
                    a.entrp_id,
                    a.start_date
                from
                    account a
                where
                        a.account_type = p_account_type
                    and a.start_date between p_start_date and p_end_date
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history
                        where
                            acc_num = a.acc_num
                    )
                union
                select
                    a.salesrep_id,
                    a.acc_num,
                    a.entrp_id,
                    a.start_date
                from
                    sales_commission_history a,
                    account                  b
                where
                        a.acc_num = b.acc_num
                    and b.account_type = p_account_type
                    and a.start_date between p_start_date and p_end_date
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := 'N';
                l_record.entrp_id := x.entrp_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                pipe row ( l_record );
            end loop;

        elsif p_account_type = 'ERISA_WRAP' then
            for x in (
                select
                    a.salesrep_id,
                    a.acc_num,
                    a.entrp_id,
                    a.start_date
                from
                    account a
                where
                        a.account_type = p_account_type
                    and a.start_date between p_start_date and p_end_date
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history
                        where
                            acc_num = a.acc_num
                    )
                union
                select
                    a.salesrep_id,
                    a.acc_num,
                    a.entrp_id,
                    a.start_date
                from
                    sales_commission_history a,
                    account                  b
                where
                        a.acc_num = b.acc_num
                    and b.account_type = p_account_type
                    and a.start_date between p_start_date and p_end_date
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.entrp_id := x.entrp_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                pipe row ( l_record );
            end loop;
        elsif p_account_type = 'HSA' then
            for x in (
                select
                    account.acc_num,
                    account.salesrep_id,
                    pc_account.get_employer_status(person.entrp_id,
                                                   to_char(p_start_date, 'MM/DD/YYYY'),
                                                   to_char(p_end_date, 'MM/DD/YYYY')) status,
                    person.entrp_id,
                    account.acc_id
                from
                    person,
                    account,
                    plans
                where
                        account.pers_id = person.pers_id
                    --     AND   ACCOUNT.SALESREP_ID IS NOT NULL
                    and person.person_type <> 'BROKER'
                    and trunc(account.start_date) >= p_start_date
                    and trunc(account.start_date) <= p_end_date
                    and account.account_type = 'HSA'
                    and account.account_status in ( 1, 2 )
                    and account.plan_code = plans.plan_code
                    and plans.plan_sign = 'SHA'
                    and 0 = (
                        select
                            count(*)
                        from
                            sales_commission_history b
                        where
                            account.acc_num = b.acc_num
                    )
                union
                select
                    b.acc_num,
                    a.salesrep_id,
                    a.account_type,
                    a.entrp_id,
                    b.acc_id
                from
                    sales_commission_history a,
                    account                  b
                where
                        trunc(a.start_date) >= p_start_date
                    and trunc(a.start_date) <= p_end_date
                    and a.pers_id = b.pers_id
                    and b.account_type = 'HSA'
            ) loop
                l_record.er_acc_num := pc_entrp.get_acc_num(x.entrp_id);
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.status;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.entrp_id := x.entrp_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                pipe row ( l_record );
            end loop;
        elsif p_account_type in ( 'HRA', 'FSA', 'COBRA' ) then
            for x in (
                select
                    acc_num,
                    salesrep_id,
                    renewal,
                    renewal_date,
                    entrp_id,
                    start_date
                from
                    (
                        select
                            a.acc_num,
                            a.salesrep_id,
                            c.entrp_id,
                            'N'  renewal,
                            null renewal_date,
                            a.start_date
                        from
                            account a,
                            person  c
                        where
                                a.pers_id = c.pers_id
                            and a.account_status <> 5
               -- AND    B.PRODUCT_TYPE = p_account_type
              --  AND    A.ACCOUNT_TYPE IN ('HRA','FSA')
                            and a.account_type = p_account_type
                            and a.start_date between p_start_date and p_end_date
                        group by
                            a.acc_num,
                            a.salesrep_id,
                            c.entrp_id,
                            a.start_date
                        union
                        select distinct
                            a.acc_num,
                            a.salesrep_id,
                            d.entrp_id,
                            'Y',
                            b.plan_start_date renewal_date,
                            a.start_date
                        from
                            ben_plan_enrollment_setup b,
                            ben_plan_enrollment_setup c,
                            account                   a,
                            person                    d
                        where
                                a.acc_id = b.acc_id
                            and b.entrp_id is null
                            and a.entrp_id is null
                            and c.acc_id = b.acc_id
                            and a.account_type = p_account_type
                            and c.plan_type = b.plan_type
                            and b.status in ( 'A', 'I' )
                            and b.plan_start_date between p_start_date and p_end_date
            --      AND B.RENEWAL_FLAG = 'Y'
                            and b.plan_start_date > c.plan_start_date
                            and d.pers_id = a.pers_id
                    ) a
                order by
                    1
            ) loop
                l_record.er_acc_num := pc_entrp.get_acc_num(x.entrp_id);
                l_record.acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.entrp_id := x.entrp_id;
         --   L_RECORD.NO_OF_ACCOUNTS  := 0;
                l_record.renewal := x.renewal;
                l_record.renewal_date := x.renewal_date;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                pipe row ( l_record );
            end loop;

            for x in (
                select
                    acc_num,
                    salesrep_id,
                    renewal,
                    renewal_date,
                    entrp_id,
                    start_date
                from
                    (
                        select
                            a.acc_num,
                            a.salesrep_id,
                            a.entrp_id,
                            sum(
                                case
                                    when b.product_type = p_account_type
                                         and b.renewal_flag = 'Y' then
                                        1
                                    else
                                        0
                                end
                            )                      renewal,
                            max(b.plan_start_date) renewal_date,
                            a.start_date
                        from
                            account                   a,
                            ben_plan_enrollment_setup b
                        where
                                a.acc_id = b.acc_id
                            and b.product_type = p_account_type
                            and a.account_type in ( 'HRA', 'FSA' )
                            and b.plan_docs_flag = 'Y'
                            and b.status <> 'R'
                            and a.start_date between p_start_date and p_end_date
                        group by
                            a.acc_num,
                            a.salesrep_id,
                            a.entrp_id,
                            a.start_date
                    ) a
                order by
                    1
            ) loop
                l_record.er_acc_num := pc_entrp.get_acc_num(x.entrp_id);
                l_record.acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.entrp_id := x.entrp_id;
         --   L_RECORD.NO_OF_ACCOUNTS  := 0;
                l_record.renewal := 'N';
                l_record.renewal_date := x.renewal_date;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                if x.renewal = 0 then
                    l_record.renewal := 'N';
                else
                    l_record.renewal := 'Y';
                end if;

                l_record.plan_doc_flag := 'Y';
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                pipe row ( l_record );
            end loop;

        end if;
    end get_summary_enrolled_report;

    procedure insert_sales_comm_data (
        p_start_date in date,
        p_end_date   in date,
        p_user_id    in number
    ) is
        l_record   enrolled_row;
        l_entrp_id number := 0;
    begin
    /* Create New commision entries for Setup fee for all accounts except HSA */
        insert into sales_commissions_detail (
            sal_comm_detail_id,
            salesrep_id,
            acc_num,
            acc_id,
            entrp_id,
            amount,
            check_date,
            start_date,
            broker_id,
            invoice_id,
            account_type,
            comm_flag,
            first_payment_date,
            period_start_date,
            period_end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            employer_payment_id,
            process_flag
        )
            (
                select
                    sales_comm_det_seq.nextval
                                     --,A.SALESREP_ID --Primary Salesrep will be always stored in Account table salesrep_id
                                    /*Ticket#5022,NEW commissions will go to Primary Salesrep */,
                    ar.salesrep_id -- 7703:Joshi Primary Salesrep should be picked from AR_INVOICE table.
                    ,
                    a.acc_num,
                    a.acc_id,
                    a.entrp_id,
                    d.check_amount,
                    d.check_date,
                    a.start_date,
                    broker_id,
                    d.invoice_id
                       --  ,  CASE WHEN A.ACCOUNT_TYPE IN ('FSA','HRA') THEN   NVL(D.PLAN_TYPE,A.ACCOUNT_TYPE)ELSE A.ACCOUNT_TYPE END PRODUCT_TYPE
                    ,
                    a.account_type product_type,
                    'NEW',
                    case
                        when d.reason_code = 1 then
                            d.check_date
                        else
                            null
                    end            first_payment_date,
                    p_start_date   period_start_date,
                    p_end_date     period_end_date,
                    sysdate        creation_date,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    d.employer_payment_id,
                    'N'
                from
                    account           a,
                    employer_payments d,
                    ar_invoice        ar
                where
                        a.account_type <> 'HSA'
                    and a.entrp_id = d.entrp_id
                    and trunc(a.reg_date) <= '01-FEB-2019'  --SK Added on 03_31_2019 to stop paying any new groups
                    and ar.invoice_id = d.invoice_id
                    and a.start_date >= p_effective_date
                    and ( ( a.account_type <> 'COBRA'
                            and d.reason_code in ( 1, 100 ) )
                          or ( a.account_type = 'COBRA'
                               and d.reason_code not in ( 11, 12, 13, 19, 23,
                                                          30 ) ) )
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and not exists (
                        select
                            *
                        from
                            sales_commissions_detail f
                        where
                            d.entrp_id = f.entrp_id
                    )
            );

               /*** If there are more than setup fee paid , or refund has been issued check to make sure if there is already
                    commission paid for it or we have already insereted it ***/

        insert into sales_commissions_detail (
            sal_comm_detail_id,
            salesrep_id,
            acc_num,
            acc_id,
            entrp_id,
            amount,
            check_date,
            start_date,
            broker_id,
            invoice_id,
            account_type,
            comm_flag,
            first_payment_date,
            period_start_date,
            period_end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            employer_payment_id,
            process_flag
        )
            (
                select
                    sales_comm_det_seq.nextval
                                        /*Ticket#5022,NEW commissions will go to Primary Salesrep */
                                     --,  A.SALESREP_ID --Primary Salesrep will be always stored in Account table salesrep_id
                    ,
                    ar.salesrep_id -- 7703:Joshi Primary Salesrep should be picked from AR_INVOICE table.
                    ,
                    a.acc_num,
                    a.acc_id,
                    a.entrp_id,
                    case
                        when d.reason_code = 23 then
                            - d.check_amount
                        else
                            d.check_amount
                    end,
                    d.check_date,
                    a.start_date,
                    broker_id,
                    d.invoice_id,
                    case
                        when a.account_type in ( 'FSA', 'HRA' ) then
                            nvl(d.plan_type, a.account_type)
                        else
                            a.account_type
                    end          product_type,
                    'NEW',
                    case
                        when d.reason_code = 1 then
                            d.check_date
                        else
                            null
                    end          first_payment_date,
                    p_start_date period_start_date,
                    p_end_date   period_end_date,
                    sysdate      creation_date,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    d.employer_payment_id,
                    'N'
                from
                    account           a,
                    employer_payments d,
                    ar_invoice        ar
                where
                        a.account_type <> 'HSA'
                    and a.entrp_id = d.entrp_id
                    and ar.invoice_id = d.invoice_id
                    and a.start_date >= p_effective_date
                    and ( ( a.account_type <> 'COBRA'
                            and d.reason_code in ( 1, 100, 23 ) )
                          or ( a.account_type = 'COBRA'
                               and d.reason_code not in ( 11, 12, 19, 30 ) ) )
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and exists (
                        select
                            *
                        from
                            sales_commissions_detail f
                        where
                            d.entrp_id = f.entrp_id
                    )
                    and not exists (
                        select
                            *
                        from
                            sales_commissions_detail f
                        where
                                d.entrp_id = f.entrp_id
                            and f.employer_payment_id = d.employer_payment_id
                    )
            );
           /* First Month fee for HSA */

        insert into sales_commissions_detail (
            sal_comm_detail_id,
            salesrep_id,
            acc_num,
            acc_id,
            entrp_id,
            amount,
            check_date,
            start_date,
            broker_id,
            invoice_id,
            account_type,
            comm_flag,
            first_payment_date,
            period_start_date,
            period_end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            change_num,
            process_flag
        )
            (
                select
                    sales_comm_det_seq.nextval,
                    salesrep_id,
                    acc_num,
                    acc_id,
                    entrp_id,
                    amount,
                    pay_date,
                    start_date   start_date,
                    broker_id,
                    null         invoice_id,
                    'HSA'        account_type,
                    'NEW',
                    nvl(first_payment_date, first_fee_date),
                    p_start_date period_start_date,
                    p_end_date   period_end_date,
                    sysdate      creation_date,
                    p_user_id    created_by,
                    sysdate      last_update_date,
                    p_user_id    last_updated_by,
                    change_num,
                    flag
                from
                    (
                        select
                   /*Ticket#5022,NEW commissions will go to Primary Salesrep */
                            account.salesrep_id --Primary Salesrep will be always stored in Account table salesrep_id
                            ,
                            account.acc_num,
                            account.acc_id,
                            a.entrp_id,
                            p.amount,
                            account.start_date start_date,
                            broker_id,
                            (
                                select
                                    min(check_date)
                                from
                                    employer_deposits
                                where
                                    entrp_id = a.entrp_id
                            )                  first_payment_date,
                            (
                                select
                                    min(pay_date)
                                from
                                    payment pp
                                where
                                    pp.acc_id = p.acc_id
                            )                  first_fee_date,
                            p.pay_date,
                            p.change_num,
                            'N'                flag
                        from
                            person  a,
                            account,
                            payment p
                        where
                                account.account_type = 'HSA'
                            and account.start_date >= p_effective_date
                            and account.start_date between p_start_date and p_end_date
                            and account.pers_id = a.pers_id
                            and p.acc_id = account.acc_id
                            and a.entrp_id is not null
                            and trunc(p.pay_date) between p_start_date and p_end_date
                            and account.salesrep_id is not null
                            and a.person_type <> 'BROKER'
                            and p.reason_code in ( 2, 100 )
                    ) x /* Monthly and annual fee */
            --WHERE NVL(FIRST_PAYMENT_DATE ,FIRST_fEE_DATE) >= P_EFFECTIVE_dATE
                where
                        first_payment_date >= p_effective_date
                    and months_between(pay_date,
                                       nvl(first_payment_date, first_fee_date)) <= 12
                    and not exists (
                        select
                            *
                        from
                            sales_commissions_detail f
                        where
                            x.acc_id = f.acc_id
                    )
            );

          /*Subsequent months Fee for HSA*/
        insert into sales_commissions_detail (
            sal_comm_detail_id,
            salesrep_id,
            acc_num,
            acc_id,
            entrp_id,
            amount,
            check_date,
            start_date,
            broker_id,
            invoice_id,
            account_type,
            comm_flag,
            first_payment_date,
            period_start_date,
            period_end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            change_num,
            process_flag
        )
            (
                select
                    sales_comm_det_seq.nextval
                            /*Ticket#5022,NEW commissions will go to Primary Salesrep */,
                    a.salesrep_id --Primary Salesrep will be always stored in Account table salesrep_id
                    ,
                    sc.acc_num,
                    sc.acc_id,
                    sc.entrp_id,
                    p.amount,
                    p.pay_date,
                    sc.start_date,
                    sc.broker_id,
                    sc.invoice_id,
                    'HSA'        account_type,
                    'MONTHLY',
                    sc.first_payment_date,
                    p_start_date period_start_date,
                    p_end_date   period_end_date,
                    sysdate      creation_date,
                    p_user_id    created_by,
                    sysdate      last_update_date,
                    p_user_id    last_updated_by,
                    p.change_num,
                    'N'
                from
                    sales_commissions_detail sc,
                    payment                  p,
                    account                  a
                where
                        sc.acc_id = p.acc_id
                    and sc.account_type = 'HSA'
                    and p.reason_code in ( 2, 100 ) /* 100 is for Annual fee */
                    and a.acc_id = sc.acc_id
                    and sc.comm_flag = 'NEW'
                    and trunc(p.pay_date) between p_start_date and p_end_date
     --            AND  trunc(months_between(P_START_DATE,SC.PERIOD_START_DATE)) = 1
                    and months_between(p.pay_date, first_payment_date) <= 12
                    and exists (
                        select
                            *
                        from
                            sales_commissions_detail f
                        where
                                sc.acc_id = f.acc_id
                            and comm_flag = 'NEW'
                    )
                    and not exists (
                        select
                            *
                        from
                            sales_commissions_detail f
                        where
                                sc.acc_id = f.acc_id
                            and f.change_num = p.change_num
                    )
            );

     /* Monthly fee insertions for HRA/FSA */
        insert into sales_commissions_detail (
            sal_comm_detail_id,
            salesrep_id,
            acc_num,
            acc_id,
            entrp_id,
            amount,
            check_date,
            start_date,
            broker_id,
            invoice_id,
            account_type,
            comm_flag,
            first_payment_date,
            period_start_date,
            period_end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            employer_payment_id,
            process_flag
        )
            (
                select
                    sales_comm_det_seq.nextval,
                    salesrep_id,
                    acc_num,
                    acc_id,
                    entrp_id,
                    check_amount,
                    check_date,
                    start_date,
                    broker_id,
                    invoice_id,
                    product_type,
                    'MONTHLY',
                    null         first_payment_date,
                    p_start_date period_start_date,
                    p_end_date   period_end_date,
                    sysdate      creation_date,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    employer_payment_id,
                    flag
                from
                    (
                        select distinct
                                       /*Ticket#5022,NEW commissions will go to Primary Salesrep */
                                      --  A.SALESREP_ID --Primary Salesrep will be always stored in Account table salesrep_id
                            ar.salesrep_id -- 7703:Joshi Primary Salesrep should be picked from AR_INVOICE table.
                            ,
                            a.acc_num,
                            a.acc_id,
                            a.entrp_id,
                            p.check_amount,
                            a.start_date,
                            p.check_date,
                            a.broker_id,
                            p.invoice_id,
                            case
                                when a.account_type in ( 'FSA', 'HRA' ) then
                                    nvl(p.plan_type, a.account_type)
                                else
                                    a.account_type
                            end product_type,
                            p.employer_payment_id,
                            'N' flag
                        from
                            sales_commissions_detail sc,
                            employer_payments        p,
                            account                  a,
                            ar_invoice               ar
                        where
                                sc.entrp_id = p.entrp_id
                            and sc.account_type in ( 'FSA', 'HRA' )
                            and trunc(a.reg_date) <= '01-FEB-2019' --SK Added on 03_31_2019 to stop paying any new groups
                            and p.reason_code in ( 2, 67, 68 )
                            and a.acc_id = sc.acc_id
                            and ar.invoice_id = p.invoice_id
                            and trunc(p.check_date) between p_start_date and p_end_date
                            and sc.comm_flag = 'NEW'
                            and trunc(months_between(p_start_date, sc.period_start_date)) <= 12
                            and exists (
                                select
                                    *
                                from
                                    sales_commissions_detail f
                                where
                                        sc.acc_id = f.acc_id
                                    and comm_flag = 'NEW'
                            )
                            and not exists (
                                select
                                    *
                                from
                                    sales_commissions_detail f
                                where
                                        sc.entrp_id = f.entrp_id
                                    and f.employer_payment_id = p.employer_payment_id
                            )
                    )
            );

       /* Create Entry for REnewals for all products*/
        insert into sales_commissions_detail (
            sal_comm_detail_id,
            salesrep_id,
            acc_num,
            acc_id,
            entrp_id,
            amount,
            start_date,
            broker_id,
            invoice_id,
            account_type,
            comm_flag,
            first_payment_date,
            period_start_date,
            period_end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            employer_payment_id,
            process_flag
        )
            (
                select
                    sales_comm_det_seq.nextval
                           /*Ticket#5022,Renewal commissions will go to Secondary Salesrep */
                          --,  A.AM_ID --Secondary Salesrep will be stored as AM_ID(Account manager id in account table)
                    ,
                    ar.am_id -- 7703:Joshi Account manager should be picked from AR_INVOICE table.
                    ,
                    a.acc_num,
                    a.acc_id,
                    a.entrp_id,
                    d.check_amount,
                    a.start_date,
                    broker_id,
                    d.invoice_id
                         -- ,  CASE WHEN A.ACCOUNT_TYPE IN ('FSA','HRA') THEN NVL(D.PLAN_TYPE,A.ACCOUNT_TYPE) ELSE A.ACCOUNT_TYPE END PRODUCT_TYPE
                    ,
                    a.account_type product_type,
                    'RENEWAL',
                    null           first_payment_date,
                    p_start_date   period_start_date,
                    p_end_date     period_end_date,
                    sysdate        creation_date,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    employer_payment_id,
                    'N'
                from
                    account           a,
                    employer_payments d,
                    ar_invoice        ar
                where
                        a.account_type <> 'HSA'
                    and a.entrp_id = d.entrp_id
                    and ar.invoice_id = d.invoice_id
                    and d.reason_code = 30
                    and trunc(d.transaction_date) between p_start_date and p_end_date
            );

    end insert_sales_comm_data;

    function get_summary_salesrep_report (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return enrolled_row_t
        pipelined
        deterministic
    is
        l_record   enrolled_row;
        l_entrp_id number := 0;
    begin
  /*Date IF for Ticket#5022*/
        if trunc(p_start_date) < p_effective_date then
            if p_account_type in ( 'FORM_5500', 'CMP' ) then --Removed POP from this list 09/30/2018
                for x in (
                    select
                        a.salesrep_id,
                        'N' renewal,
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        d.check_amount,
                        a.start_date,
                        broker_id,
                        d.invoice_id
                    from
                        account           a,
                        employer_payments d
                    where
                            a.account_type = p_account_type
                        and a.entrp_id = d.entrp_id
                        and d.reason_code = 1
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                s.acc_num = a.acc_num
                        )
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := 'N';
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    l_record.invoice_id := x.invoice_id;
                    pipe row ( l_record );
                end loop;
            --Ticket#3690. Add renewal Entry for FORM5500 and Compliance products
                for x in (
                    select
                        a.salesrep_id,
                        'Y' renewal,
                        a.acc_num,
                        a.entrp_id,
                        d.reason_code,
                        a.acc_id,
                        d.check_amount,
                        a.start_date,
                        broker_id
                    from
                        account           a,
                        employer_payments d
                    where
                            a.account_type = p_account_type
                        and a.entrp_id = d.entrp_id
                        and d.reason_code = 30
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                s.acc_num = a.acc_num
                        )
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                    s.acc_num = a.acc_num
                                and s.account_type = 'Renewal'
                                and s.creation_date >= p_start_date
                                and fee_paid > 0
                        )
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.renewal;
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    pipe row ( l_record );
                end loop;
            --End of Ticket#3690
            elsif p_account_type = 'COBRA' then
                for x in (
                    select
                        a.salesrep_id,
                        'N'                 renewal,
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        a.start_date,
                        broker_id,
                        sum(d.check_amount) check_amount,
                        d.invoice_id
                    from
                        account           a,
                        employer_payments d
                    where
                            a.account_type = p_account_type
                        and a.entrp_id = d.entrp_id
                        and d.reason_code not in ( 11, 12, 19 )
                        and a.account_status = 1
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and exists (
                            select
                                *
                            from
                                employer_payments e
                            where
                                    d.entrp_id = e.entrp_id
                                and e.reason_code = 1
                                and trunc(e.transaction_date) between p_start_date and p_end_date
                        )
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                s.acc_num = a.acc_num
                        )
                    group by
                        a.salesrep_id,
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        a.start_date,
                        broker_id,
                        d.invoice_id
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.renewal;
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    l_record.invoice_id := x.invoice_id;
                    pipe row ( l_record );
                end loop;

                for x in (
                    select
                        a.salesrep_id,
                        'Y'                 renewal,
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        a.start_date,
                        broker_id,
                        sum(d.check_amount) check_amount,
                        d.invoice_id
                    from
                        account           a,
                        employer_payments d
                    where
                            a.account_type = p_account_type
                        and a.entrp_id = d.entrp_id
                        and d.reason_code not in ( 11, 12, 19 )
                        and a.account_status = 1
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and exists (
                            select
                                *
                            from
                                employer_payments e
                            where
                                    d.entrp_id = e.entrp_id
                                and e.reason_code <> 1
                                and trunc(e.transaction_date) between p_start_date and p_end_date
                        )
                        and not exists (
                            select
                                *
                            from
                                employer_payments e
                            where
                                    d.entrp_id = e.entrp_id
                                and e.reason_code in ( 1, 23 )
                                and trunc(e.transaction_date) between p_start_date and p_end_date
                        )
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                    s.acc_num = a.acc_num
                                and s.account_type = 'Renewal'
                                and s.creation_date >= p_start_date
                                and fee_paid > 0
                        )
                    group by
                        a.salesrep_id,
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        a.start_date,
                        broker_id,
                        d.invoice_id
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.renewal;
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    l_record.invoice_id := x.invoice_id;
                    pipe row ( l_record );
                end loop;

            elsif p_account_type = 'ERISA_WRAP' then
                for x in (
                    select
                        a.salesrep_id,
                        'N' renewal,
                        a.acc_num,
                        a.entrp_id,
                        d.reason_code,
                        a.acc_id,
                        d.check_amount,
                        a.start_date,
                        broker_id
                    from
                        account           a,
                        employer_payments d
                    where
                            a.account_type = p_account_type
                        and a.entrp_id = d.entrp_id
                        and d.reason_code in ( 1, 30, 100 )
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                s.acc_num = a.acc_num
                        )
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.renewal;
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    pipe row ( l_record );
                end loop;

                for x in (
                    select
                        a.salesrep_id,
                        'Y' renewal,
                        a.acc_num,
                        a.entrp_id,
                        d.reason_code,
                        a.acc_id,
                        d.check_amount,
                        a.start_date,
                        broker_id
                    from
                        account           a,
                        employer_payments d
                    where
                            a.account_type = p_account_type
                        and a.entrp_id = d.entrp_id
                        and d.reason_code = 30
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                s.acc_num = a.acc_num
                        )
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                    s.acc_num = a.acc_num
                                and s.account_type = 'Renewal'
                                and s.creation_date >= p_start_date
                                and fee_paid > 0
                        )
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.renewal;
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    pipe row ( l_record );
                end loop;

            elsif p_account_type = 'HSA' then
                for x in (
                    select
                        account.acc_num,
                        account.salesrep_id,
                        pc_account.get_employer_status(person.entrp_id,
                                                       to_char(p_start_date, 'MM/DD/YYYY'),
                                                       to_char(p_end_date, 'MM/DD/YYYY')) status,
                        person.entrp_id,
                        account.acc_id,
                        to_char(account.start_date, 'MM/DD/YYYY')     start_date,
                        broker_id
                    from
                        person,
                        account,
                        plans
                    where
                            account.pers_id = person.pers_id
                        and account.salesrep_id is not null
                        and person.person_type <> 'BROKER'
                        and trunc(account.start_date) >= p_start_date
                        and trunc(account.start_date) <= p_end_date
                        and account.account_type = 'HSA'
                        and account.account_status in ( 1, 2 )
                        and account.plan_code = plans.plan_code
                        and plans.plan_sign = 'SHA'
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history b
                            where
                                account.acc_num = b.acc_num
                        )
                ) loop
                    l_record.er_acc_num := pc_entrp.get_acc_num(x.entrp_id);
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.status;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.entrp_id := x.entrp_id;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.effective_date := x.start_date;
                    l_record.broker_id := x.broker_id;
                    pipe row ( l_record );
                end loop;
            elsif p_account_type in ( 'HRA', 'FSA' ) then
                for x in (
                    select
                        a.salesrep_id,
                        decode(d.reason_code, 1, 'N', 30, 'Y') renewal,
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        d.plan_type,
                        a.start_date,
                        broker_id,
                        sum(d.check_amount)                    check_amount
                    from
                        account           a,
                        employer_payments d
                    where
                            d.plan_type = p_account_type
                        and a.account_type in ( 'HRA', 'FSA' )
                        and a.entrp_id = d.entrp_id
                        and d.reason_code = 1
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                    s.acc_num = a.acc_num
                                and s.product_type = p_account_type
                        )
                    group by
                        a.salesrep_id,
                        decode(d.reason_code, 1, 'N', 30, 'Y'),
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        a.start_date,
                        d.plan_type,
                        broker_id
                    having
                        sum(check_amount) > 0
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.renewal;
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.product_type := x.plan_type;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.plan_doc_flag := is_plan_doc_only(x.entrp_id, p_account_type, p_start_date, p_end_date);
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    pipe row ( l_record );
                end loop;

                for x in (
                    select
                        a.salesrep_id,
                        decode(d.reason_code, 1, 'N', 30, 'Y') renewal,
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        d.plan_type,
                        a.start_date,
                        broker_id,
                        sum(d.check_amount)                    check_amount,
                        (
                            select
                                max(renewal_date)
                            from
                                ben_plan_enrollment_setup c
                            where
                                    c.entrp_id = a.entrp_id
                                and c.product_type = p_account_type
                                and c.status <> 'R'
                        )                                      renewal_date
                    from
                        account           a,
                        employer_payments d
                    where
                            d.plan_type = p_account_type
                        and a.account_type in ( 'HRA', 'FSA' )
                        and a.entrp_id = d.entrp_id
                        and d.reason_code = 30
                        and trunc(d.transaction_date) between p_start_date and p_end_date
                        and not exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                    s.acc_num = a.acc_num
                                and period_start_date >= p_start_date
                                and period_end_date <= p_end_date
                                and fee_paid > 0
                        )
                        and exists (
                            select
                                *
                            from
                                sales_commission_history s
                            where
                                s.acc_num = a.acc_num
                        )
                    group by
                        a.salesrep_id,
                        decode(d.reason_code, 1, 'N', 30, 'Y'),
                        a.acc_num,
                        a.entrp_id,
                        a.acc_id,
                        a.start_date,
                        broker_id,
                        d.plan_type
                    having
                        sum(check_amount) > 0
                ) loop
                    l_record.er_acc_num := x.acc_num;
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.renewal := x.renewal;
                    l_record.entrp_id := x.entrp_id;
                    l_record.acc_num := x.acc_num;
                    l_record.acc_id := x.acc_id;
                    l_record.product_type := x.plan_type;
                    l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                    l_record.fee_amount := x.check_amount;
                    l_record.renewal_date := x.renewal_date;
                    l_record.plan_doc_flag := is_plan_doc_only(x.entrp_id, p_account_type, p_start_date, p_end_date);
                    l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                    l_record.broker_id := x.broker_id;
                    pipe row ( l_record );
                end loop;

            end if;

        else /* Date is > 01-FEB-2018 */
            for x in (
                select
                    a.salesrep_id,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    a.amount,
                    a.start_date,
                    a.broker_id,
                    a.invoice_id
                           --,  --DECODE(A.COMM_FLAG,'Y','RENEWAL','NEW') RENEWAL
                    ,
                    comm_flag renewal
                from
                    sales_commissions_detail a
                where
                        account_type = p_account_type
                    and trunc(period_start_date) >= p_start_date
                    and trunc(period_end_date) <= p_end_date
                    and process_flag = 'N'
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.amount;
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                l_record.invoice_id := x.invoice_id;
                pipe row ( l_record );
            end loop;
        end if;
    end get_summary_salesrep_report;

    procedure archive_hra_fsa_commission (
        p_start_date in varchar2,
        p_end_date   in varchar2,
        p_entrp_id   in number,
        p_user_id    in number
    ) is
    begin
        insert into sales_commission_history (
            acc_num,
            employer,
            account_status,
            broker,
            user_name,
            sales_rep,
            account_type,
            start_date,
            no_of_ee,
            created_by,
            creation_date,
            salesrep_id,
            entrp_id,
            no_of_hra,
            no_of_fsa,
            no_of_dca,
            no_of_trn,
            no_of_pkg,
            no_of_lpf,
            no_of_iir
        )
            select
                acc_num,
                name,
                'Active',
                nvl(
                    pc_account.get_broker(account.broker_id),
                    'No Broker On Record'
                )                                                 broker,
                get_user_name(account.created_by)                 user_name,
                pc_account.get_salesrep_name(account.salesrep_id),
                account.account_type,
                account.reg_date,
                pc_entrp.count_active_person(enterprise.entrp_id) no_of_emp,
                p_user_id,
                sysdate,
                account.salesrep_id,
                account.entrp_id,
                (
                    select
                        count(distinct acc.acc_id)
                    from
                        ben_plan_enrollment_setup x,
                        person                    p,
                        account                   acc
                    where
                            x.acc_id = acc.acc_id
                        and p.pers_id = acc.pers_id
                        and p.entrp_id = enterprise.entrp_id
                        and x.status in ( 'A', 'I' )
                        and x.plan_type in ( 'HRP', 'HR5', 'HR4', 'HRA', 'ACO' )
                )                                                 no_of_hra,
                (
                    select
                        count(distinct acc.acc_id)
                    from
                        ben_plan_enrollment_setup x,
                        person                    p,
                        account                   acc
                    where
                            x.acc_id = acc.acc_id
                        and p.pers_id = acc.pers_id
                        and p.entrp_id = enterprise.entrp_id
                        and x.status in ( 'A', 'I' )
                        and x.plan_type = 'FSA'
                )                                                 no_of_fsa,
                (
                    select
                        count(distinct acc.acc_id)
                    from
                        ben_plan_enrollment_setup x,
                        person                    p,
                        account                   acc
                    where
                            x.acc_id = acc.acc_id
                        and p.pers_id = acc.pers_id
                        and p.entrp_id = enterprise.entrp_id
                        and x.status in ( 'A', 'I' )
                        and x.plan_type = 'FSA'
                )                                                 no_of_dca,
                (
                    select
                        count(distinct acc.acc_id)
                    from
                        ben_plan_enrollment_setup x,
                        person                    p,
                        account                   acc
                    where
                            x.acc_id = acc.acc_id
                        and p.pers_id = acc.pers_id
                        and p.entrp_id = enterprise.entrp_id
                        and x.status in ( 'A', 'I' )
                        and x.plan_type = 'TRN'
                )                                                 no_of_trn,
                (
                    select
                        count(distinct acc.acc_id)
                    from
                        ben_plan_enrollment_setup x,
                        person                    p,
                        account                   acc
                    where
                            x.acc_id = acc.acc_id
                        and p.pers_id = acc.pers_id
                        and p.entrp_id = enterprise.entrp_id
                        and x.status in ( 'A', 'I' )
                        and x.plan_type = 'TRN'
                )                                                 no_of_pkg,
                (
                    select
                        count(distinct acc.acc_id)
                    from
                        ben_plan_enrollment_setup x,
                        person                    p,
                        account                   acc
                    where
                            x.acc_id = acc.acc_id
                        and p.pers_id = acc.pers_id
                        and p.entrp_id = enterprise.entrp_id
                        and x.status in ( 'A', 'I' )
                        and x.plan_type = 'LPF'
                )                                                 no_of_lpf,
                (
                    select
                        count(distinct acc.acc_id)
                    from
                        ben_plan_enrollment_setup x,
                        person                    p,
                        account                   acc
                    where
                            x.acc_id = acc.acc_id
                        and p.pers_id = acc.pers_id
                        and p.entrp_id = enterprise.entrp_id
                        and x.status in ( 'A', 'I' )
                        and x.plan_type = 'IIR'
                )                                                 no_of_iir
            from
                enterprise,
                account
            where
                    account.entrp_id = p_entrp_id
                and account.entrp_id = enterprise.entrp_id
                and enterprise.en_code = 1
                and account_type in ( 'HRA', 'FSA' )
                and name not like 'test%'
                and trunc(account.reg_date) >= to_date(p_start_date, 'MM/DD/YYYY')
                and trunc(account.reg_date) <= to_date(p_end_date, 'MM/DD/YYYY')
                and not exists (
                    select
                        *
                    from
                        sales_commission_history
                    where
                        acc_num = account.acc_num
                )
                and pc_entrp.count_active_person(enterprise.entrp_id) > 0;

    end;

    procedure archive_sales_commission (
        p_start_date in varchar2,
        p_end_date   in varchar2,
        p_user_id    in varchar2
    ) is
    begin
        insert into sales_commission_history (
            pers_id,
            first_name,
            middle_name,
            last_name,
            ssn,
            relat_name,
            acc_num,
            employer,
            account_status,
            current_balance,
            card_ordered_on,
            complete,
            broker,
            user_name,
            sales_rep,
            account_type,
            start_date,
            created_by,
            creation_date,
            salesrep_id,
            entrp_id,
            er_setup_fee,
            carrier_name
        )
            select
                person.pers_id                                                            pers_id,
                first_name,
                middle_name,
                last_name,
                ssn,
                relat_name,
                account.acc_num                                                           acc_num,
                enterprise.name                                                           employer,
                case
                    when account.acc_num is not null then
                        lookups.description
                    else
                        'Account is not created'
                end                                                                       account_status,
                case
                    when account.acc_num is not null then
                        pc_account.acc_balance(account.acc_id,
                                               '01-JAN-2004',
                                               greatest(
                                        nvl((
                                            select
                                                max(fee_date)
                                            from
                                                income
                                            where
                                                acc_id = account.acc_id
                                        ),
                                            sysdate),
                                        sysdate
                                    ))
                end                                                                       current_balance,
                to_char(card_debit.start_date, 'MM/DD/RRRR')                              card_ordered_on,
                decode(account.complete_flag, 1, 'Yes', 'No')                             complete,
                nvl(
                    pc_account.get_broker(account.broker_id),
                    'No Broker On Record'
                )                                                                         broker,
                (
                    select
                        user_name
                    from
                        sam_users
                    where
                        user_id = person.created_by
                )                                                                         user_name,
                pc_account.get_salesrep_name(account.salesrep_id)                         "Sales Rep",
                pc_account.get_employer_status(person.entrp_id, p_start_date, p_end_date) account_type,
                account.start_date,
                get_user_id(v('APP_USER')),
                sysdate,
                account.salesrep_id,
                person.entrp_id,
                pc_plan.fsetup_er(enterprise.entrp_id),
                pc_person.get_carrier_name(person.pers_id)
            from
                person,
                relative,
                account,
                enterprise,
                lookups,
                card_debit,
                plans,
                table ( pc_commission.get_summary_salesrep_report('HSA', to_date(p_start_date, 'MM/DD/RRRR'), to_date(p_end_date, 'MM/DD/RRRR'
                )) ) x
            where
                    person.relat_code = relative.relat_code (+)
                and account.pers_id = person.pers_id
                and enterprise.entrp_id (+) = person.entrp_id
                and account.account_status = lookups.lookup_code (+)
                and card_debit.card_id (+) = person.pers_id
                and lookups.lookup_name (+) = 'ACCOUNT_STATUS'
                and account.plan_code = plans.plan_code
                and account.plan_code in ( 1, 3, 2 )
                and plans.plan_sign = 'SHA'
                and account.acc_num = x.acc_num
                and not exists (
                    select
                        *
                    from
                        sales_commission_history
                    where
                        acc_num = account.acc_num
                );

    end archive_sales_commission;

    procedure archive_pop_commission (
        p_user_id  in varchar2,
        p_entrp_id in number
    ) is
    begin
        insert into sales_commission_history (
            acc_num,
            employer,
            account_status,
            broker,
            user_name,
            sales_rep,
            account_type,
            start_date,
            created_by,
            creation_date,
            salesrep_id,
            entrp_id
        )
            select
                account.acc_num                            acc_num,
                enterprise.name                            employer,
                lookups.description                        account_status,
                nvl(
                    pc_account.get_broker(account.broker_id),
                    'No Broker On Record'
                )                                          broker,
                get_user_name(account.created_by)          user_name,
                pc_account.get_salesrep(account.broker_id) "Sales Rep",
                'POP'                                      account_type,
                account.start_date,
                get_user_id(v('APP_USER')),
                sysdate,
                account.salesrep_id,
                account.entrp_id
            from
                account,
                enterprise,
                lookups,
                plans
            where
                    account.entrp_id = p_entrp_id
                and account.entrp_id = enterprise.entrp_id
                and account.account_status = lookups.lookup_code (+)
                and lookups.lookup_name (+) = 'ACCOUNT_STATUS'
                and account.account_status = 1
                and account.plan_code = plans.plan_code
                and plans.plan_sign = 'SHA'
                and account.account_type = 'POP'
                and not exists (
                    select
                        *
                    from
                        sales_commission_history
                    where
                        acc_num = account.acc_num
                );

    end archive_pop_commission;

    function get_commission_amount (
        p_account_type in varchar2,
        p_renewal_flag in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_comm_amt number := 0;
    begin
        for x in (
            select
                decode(comm_method, 'AMOUNT', comm_amount, comm_perc / 100) comm_amt
            from
                sales_comm_rates
            where
                    account_type = p_account_type
                and account_category = p_renewal_flag
                and entity_type = 'SALESREP'
                and start_date <= p_start_date
                and nvl(end_date, p_end_date) >= p_end_date
        ) --(END_DATE IS NULL OR END_DATE <= P_END_DATE AND END_DATE >= P_START_DATE ))
         loop
            l_comm_amt := x.comm_amt;
        end loop;

        return l_comm_amt;
    end get_commission_amount;

    function get_commission (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return varchar2 is
        l_comm_amt varchar2(30);
    begin
        for x in (
            select
                decode(comm_method, 'AMOUNT', '$'
                                              || comm_amount
                                              || '.00', comm_perc || '%') comm_amt
            from
                sales_comm_rates
            where
                    account_type = p_account_type
                and entity_type = 'SALESREP'
       --         AND   START_DATE <= P_START_DATE
                and end_date is null
        ) loop
            l_comm_amt := x.comm_amt;
        end loop;

        return l_comm_amt;
    end get_commission;

    function calculate_commission (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return sales_rep_comm_row_t
        pipelined
        deterministic
    is
        l_record sales_rep_comm_row;
    begin
        if p_account_type = 'HSA' then
            for x in (
                select
                    count(distinct acc_num)                  no_of_accounts,
                    decode(renewal, 'New', 'NEW', 'RENEWAL') renewal,
                    salesrep_id
                from
                    table ( pc_commission.get_summary_salesrep_report(p_account_type, p_start_date, p_end_date) ) a
                group by
                    a.renewal,
                    salesrep_id
            ) loop
                l_record.salesrep_id := x.salesrep_id;
                l_record.account_category := x.renewal;
                l_record.account_type := p_account_type;
                l_record.quantity := x.no_of_accounts;
                l_record.period_start_date := p_start_date;
                l_record.period_end_date := p_end_date;
                l_record.comm_amt_perc := get_commission_amount(p_account_type, x.renewal, p_start_date, p_end_date);
                l_record.transaction_amount := x.no_of_accounts * l_record.comm_amt_perc;
                pipe row ( l_record );
            end loop;

        else
            for x in (
                select
                    count(distinct acc_num)                no_of_accounts,
                    decode(renewal, 'Y', 'RENEWAL', 'NEW') renewal,
                    salesrep_id,
                    entrp_id,
                    sum(nvl(fee_amount, 0))                revenue
                from
                    table ( pc_commission.get_summary_salesrep_report(p_account_type, p_start_date, p_end_date) ) a
                group by
                    a.renewal,
                    salesrep_id,
                    entrp_id
            ) loop
                if x.revenue > 0 then
                    l_record.salesrep_id := x.salesrep_id;
                    l_record.account_category := x.renewal;
                    l_record.account_type := p_account_type;
                    l_record.quantity := x.no_of_accounts;
                    l_record.period_start_date := p_start_date;
                    l_record.period_end_date := p_end_date;
                    l_record.plan_doc_flag := 'N';
                    if p_account_type = 'HRA' then
                        l_record.plan_doc_flag := is_plan_doc_only(x.entrp_id, p_account_type, p_start_date, p_end_date);
                    end if;

                    l_record.revenue_per_acct := x.revenue;--ROUND(GET_SALES_REVENUE(P_ACCOUNT_TYPE,P_START_DATE,P_END_DATE,X.REASON_CODE,X.ENTRP_ID),2);
                    if l_record.plan_doc_flag = 'Y' then
                        l_record.comm_amt_perc := get_commission_amount(p_account_type, 'PLAN_DOC', p_start_date, p_end_date);
                    else
                        l_record.comm_amt_perc := get_commission_amount(p_account_type, x.renewal, p_start_date, p_end_date);
                    end if;

                    l_record.entrp_id := x.entrp_id;

        /*       l_record.transaction_amount := l_record.REVENUE_PER_ACCT
                                             *l_record.COMM_AMT_PERC;*/

                /* As per : Commission Schedule 1/17/2014
                   Commission Notes :
                   There is a $5,000 maximum comp per group on the HRA and FSA.
                */

                    if p_account_type in ( 'FSA', 'HRA' ) then
                        l_record.transaction_amount := least(l_record.revenue_per_acct * l_record.comm_amt_perc, 5000);
                    else
                        l_record.transaction_amount := l_record.revenue_per_acct * l_record.comm_amt_perc;
                    end if;

                    pipe row ( l_record );
                end if;
            end loop;
        end if;
    end calculate_commission;

    function calculate_new_commission (
        p_account_type in varchar2 default null,
        p_start_date   in date,
        p_end_date     in date
    ) return sales_rep_comm_row_t
        pipelined
        deterministic
    is
        l_record  sales_rep_comm_row;
        l_renewal varchar2(100);
    begin
        for x in (
            select
                count(distinct acc_num) no_of_accounts,
                comm_flag               renewal,
                salesrep_id,
                entrp_id,
                account_type,
                sum(nvl(amount, 0))     revenue
            from
                sales_commissions_detail a
            where
                    period_start_date = p_start_date
                and period_end_date = p_end_date
                and account_type = nvl(p_account_type, account_type)
                     --AND  ACCOUNT_TYPE <> 'HSA'
                and process_flag = 'N'
            group by
                comm_flag,
                salesrep_id,
                entrp_id,
                account_type
        ) loop
          --  IF X.REVENUE > 0 THEN Commisions are calculated for REfund amount also which are always negative
            l_record.salesrep_id := x.salesrep_id;
            l_record.account_category := x.renewal;
            l_record.account_type := x.account_type;
            l_record.quantity := x.no_of_accounts;
            l_record.period_start_date := p_start_date;
            l_record.period_end_date := p_end_date;
            l_record.plan_doc_flag := 'N';

               /*For monthly fee,we added another category as MONTHLY for calculations. In detail table it gets stored as monthly but when we calculate
               commissions it is considered as NEW */

            if x.renewal = 'MONTHLY' then
                l_renewal := 'NEW';
            else
                l_renewal := x.renewal;
            end if;

            if x.account_type = 'HRA' then
                l_record.plan_doc_flag := is_plan_doc_only(x.entrp_id, x.account_type, p_start_date, p_end_date);
            end if;

            l_record.revenue_per_acct := x.revenue;--ROUND(GET_SALES_REVENUE(P_ACCOUNT_TYPE,P_START_DATE,P_END_DATE,X.REASON_CODE,X.ENTRP_ID),2);
            if l_record.plan_doc_flag = 'Y' then
                l_record.comm_amt_perc := get_commission_amount(x.account_type, 'PLAN_DOC', p_start_date, p_end_date);
            else
                l_record.comm_amt_perc := get_commission_amount(x.account_type, l_renewal, p_start_date, p_end_date);
            end if;

            l_record.entrp_id := x.entrp_id;
            if
                x.account_type in ( 'FSA', 'HRA' )
                and l_record.account_category = 'NEW'
            then
                l_record.transaction_amount := least(l_record.revenue_per_acct * l_record.comm_amt_perc, 5000);
            elsif
                x.account_type = 'HSA'
                and l_record.account_category in ( 'NEW', 'MONTHLY' )
            then
                l_record.transaction_amount := x.revenue * l_record.comm_amt_perc * 4;/* HSA Calculation */
            else
                l_record.transaction_amount := l_record.revenue_per_acct * l_record.comm_amt_perc;
            end if;

                /*Ticket#5022.For Renewals it is 35$* no of accounts*/
            if l_record.account_category = 'RENEWAL' then
                l_record.transaction_amount := x.no_of_accounts * l_record.comm_amt_perc;
            end if;
                /*End 5022*/

            pipe row ( l_record );
        --  END IF;
        end loop;
    end calculate_new_commission;

    function get_all_commissions (
        p_start_date in date,
        p_end_date   in date
    ) return sales_rep_comm_row_t
        pipelined
        deterministic
    is
        l_record sales_rep_comm_row;
    begin
        for xx in (
            select
                *
            from
                account_type
            where
                lookup_code <> 'COBRA'
        ) loop
            for x in (
                select
                    *
                from
                    table ( pc_commission.calculate_commission(xx.lookup_code, p_start_date, p_end_date) )
            ) loop
                l_record.salesrep_id := x.salesrep_id;
                l_record.account_category := x.account_category;
                l_record.account_type := xx.lookup_code;
                l_record.quantity := x.quantity;
                l_record.period_start_date := x.period_start_date;
                l_record.period_end_date := x.period_end_date;
                l_record.revenue_per_acct := x.revenue_per_acct;
                l_record.comm_amt_perc := x.comm_amt_perc;
                l_record.transaction_amount := x.transaction_amount;
                pipe row ( l_record );
            end loop;
        end loop;
    end get_all_commissions;

    procedure save_comm_payment (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_user_id      in number
    ) is
    begin
        for x in (
            select
                salesrep_id,
                sum(transaction_amount) transaction_amount,
                sum(revenue_per_acct)   revenue_per_acct,
                sum(quantity)           quantity,
                account_category,
                account_type
            from
                table ( pc_commission.calculate_commission(p_account_type, p_start_date, p_end_date) )
            where
                salesrep_id is not null
            group by
                account_category,
                account_type,
                salesrep_id
        ) loop
            insert into sales_comm_paid (
                comm_paid_id,
                salesrep_id,
                processed_date,
                period_start_date,
                period_end_date,
                transaction_amount,
                revenue_amount,
                quantity,
                account_category,
                account_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            )
                select
                    sales_comm_paid_seq.nextval,
                    x.salesrep_id,
                    sysdate,
                    p_start_date,
                    p_end_date,
                    x.transaction_amount,
                    x.revenue_per_acct,
                    x.quantity,
                    x.account_category,
                    x.account_type,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id
                from
                    dual
                where
                    not exists (
                        select
                            *
                        from
                            sales_comm_paid
                        where
                                account_type = p_account_type
                            and period_start_date = p_start_date
                            and period_end_date = p_end_date
                            and salesrep_id = x.salesrep_id
                            and account_category = x.account_category
                    );

        end loop;
    end save_comm_payment;

    procedure save_comm_payment_new (
        p_start_date in date,
        p_end_date   in date,
        p_user_id    in number
    ) is
    begin
        dbms_output.put_line('Here2');
        --PC_COMMISSION.INSERT_SALES_COMM_DATA(P_START_DATE,P_END_DATE ,P_USER_ID );
        /*This insert proc will be called independently in separate cron */
        for x in (
            select
                salesrep_id,
                sum(transaction_amount) transaction_amount,
                sum(revenue_per_acct)   revenue_per_acct,
                sum(quantity)           quantity,
                account_category,
                account_type
            from
                table ( pc_commission.calculate_new_commission(null, p_start_date, p_end_date) )
            where
                salesrep_id is not null
            group by
                account_category,
                account_type,
                salesrep_id
        ) loop
            insert into sales_comm_paid (
                comm_paid_id,
                salesrep_id,
                processed_date,
                period_start_date,
                period_end_date,
                transaction_amount,
                revenue_amount,
                quantity,
                account_category,
                account_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            )
                select
                    sales_comm_paid_seq.nextval,
                    x.salesrep_id,
                    sysdate,
                    p_start_date,
                    p_end_date,
                    x.transaction_amount,
                    x.revenue_per_acct,
                    x.quantity,
                    x.account_category,
                    x.account_type,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id
                from
                    dual
                where
                    not exists (
                        select
                            *
                        from
                            sales_comm_paid
                        where
                                account_type = x.account_type
                            and period_start_date = p_start_date
                            and period_end_date = p_end_date
                            and salesrep_id = x.salesrep_id
                            and account_category = x.account_category
                    );

        end loop;
      /* Once data gets inserted into Sales commission paid table, we can set the status of flag = 'Y' in detail table */
        update sales_commissions_detail
        set
            process_flag = 'Y'
        where
                period_start_date = p_start_date
            and period_end_date = p_end_date;

    end save_comm_payment_new;

    function get_payment_count (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            employer_payments
        where
            transaction_date between p_start_date and p_end_date
            and entrp_id = p_entrp_id
            and reason_code in ( 1, 100 );

        return nvl(l_count, 0);
    end get_payment_count;

    procedure save_commissions (
        p_account_type in varchar2 default null,
        p_start_date   in date,
        p_end_date     in date,
        p_user_id      in number
    ) is
    begin
        dbms_output.put_line('Here1');

     /* Ticket#5022 */
        if trunc(p_start_date) >= p_effective_date then
            dbms_output.put_line('Here1');
            pc_commission.save_comm_payment_new(p_start_date, p_end_date, p_user_id);
        else
            save_comm_payment(p_account_type, p_start_date, p_end_date, p_user_id);
            for c in (
                select
                    renewal_date,
                    er_acc_num,
                    entrp_id,
                    fee_amount,
                    acc_num,
                    renewal
                from
                    table ( pc_commission.get_summary_salesrep_report(p_account_type, p_start_date, p_end_date) )
            ) loop
                if p_account_type <> 'HSA' then
                    insert into sales_commission_history (
                        acc_num,
                        employer,
                        account_status,
                        broker,
                        user_name,
                        sales_rep,
                        account_type,
                        start_date,
                        no_of_ee,
                        created_by,
                        creation_date,
                        salesrep_id,
                        entrp_id,
                        renewal_date,
                        fee_paid,
                        period_start_date,
                        period_end_date,
                        product_type,
                        acc_id
                    )
                        select
                            account.acc_num,
                            name,
                            'Active',
                            nvl(
                                pc_account.get_broker(account.broker_id),
                                'No Broker On Record'
                            )                                                 broker,
                            get_user_name(account.created_by)                 user_name,
                            pc_account.get_salesrep_name(account.salesrep_id),
                            decode(c.renewal, 'Y', 'Renewal', 'New'),
                            account.reg_date,
                            pc_entrp.count_active_person(enterprise.entrp_id) no_of_emp,
                            p_user_id,
                            sysdate,
                            account.salesrep_id,
                            account.entrp_id,
                            c.renewal_date,
                            c.fee_amount,
                            p_start_date,
                            p_end_date,
                            p_account_type,
                            account.acc_id
                        from
                            enterprise,
                            account
                        where
                                account.entrp_id = enterprise.entrp_id
                            and enterprise.en_code = 1
                            and account.acc_num = c.er_acc_num
                            and enterprise.entrp_id = c.entrp_id
                            and account.salesrep_id is not null;

                end if;

                if p_account_type = 'HSA' then
                    insert into sales_commission_history (
                        pers_id,
                        first_name,
                        middle_name,
                        last_name,
                        ssn,
                        relat_name,
                        acc_num,
                        employer,
                        account_status,
                        current_balance,
                        card_ordered_on,
                        complete,
                        broker,
                        user_name,
                        sales_rep,
                        account_type,
                        start_date,
                        created_by,
                        creation_date,
                        salesrep_id,
                        entrp_id,
                        er_setup_fee,
                        carrier_name,
                        acc_id,
                        product_type,
                        period_start_date,
                        period_end_date
                    )
                        select
                            person.pers_id                                    pers_id,
                            first_name,
                            middle_name,
                            last_name,
                            ssn,
                            relat_name,
                            account.acc_num                                   acc_num,
                            enterprise.name                                   employer,
                            case
                                when account.acc_num is not null then
                                    lookups.description
                                else
                                    'Account is not created'
                            end                                               account_status,
                            case
                                when account.acc_num is not null then
                                    pc_account.acc_balance(account.acc_id,
                                                           '01-JAN-2004',
                                                           greatest(
                                                    nvl((
                                                        select
                                                            max(fee_date)
                                                        from
                                                            income
                                                        where
                                                            acc_id = account.acc_id
                                                    ),
                                                        sysdate),
                                                    sysdate
                                                ))
                            end                                               current_balance,
                            to_char(card_debit.start_date, 'MM/DD/RRRR')      card_ordered_on,
                            decode(account.complete_flag, 1, 'Yes', 'No')     complete,
                            nvl(
                                pc_account.get_broker(account.broker_id),
                                'No Broker On Record'
                            )                                                 broker,
                            (
                                select
                                    user_name
                                from
                                    sam_users
                                where
                                    user_id = person.created_by
                            )                                                 user_name,
                            pc_account.get_salesrep_name(account.salesrep_id) "Sales Rep",
                            pc_account.get_employer_status(person.entrp_id,
                                                           to_char(p_start_date, 'MM/DD/YYYY'),
                                                           to_char(p_end_date, 'MM/DD/YYYY'))     account_type,
                            account.start_date,
                            get_user_id(v('APP_USER')),
                            sysdate,
                            account.salesrep_id,
                            person.entrp_id,
                            pc_plan.fsetup_er(enterprise.entrp_id),
                            pc_person.get_carrier_name(person.pers_id),
                            account.acc_id,
                            'HSA',
                            p_start_date,
                            p_end_date
                        from
                            person,
                            relative,
                            account,
                            enterprise,
                            lookups,
                            card_debit,
                            plans
                        where
                                person.relat_code = relative.relat_code (+)
                            and account.pers_id = person.pers_id
                            and enterprise.entrp_id (+) = person.entrp_id
                            and account.account_status = lookups.lookup_code (+)
                            and card_debit.card_id (+) = person.pers_id
                            and lookups.lookup_name (+) = 'ACCOUNT_STATUS'
                            and account.plan_code = plans.plan_code
            --   AND   ACCOUNT.PLAN_CODE IN (1,3,2)
                            and plans.plan_sign = 'SHA'
                            and account.acc_num = c.acc_num
                            and not exists (
                                select
                                    *
                                from
                                    sales_commission_history
                                where
                                    acc_num = account.acc_num
                            );

                end if;

            end loop;

        end if;
   /*Old and New structure */

    end save_commissions;

    function get_sales_rep_tree (
        p_user_id in number
    ) return sales_rep_row_t
        pipelined
        deterministic
    is
        l_record sales_rep_row;
    begin
    -- There is a condition where the salesrep's either should see their commissions only or their managers
     -- when viewing the sales commission. If outside of sales organization then they should be able
     -- to see everyone's commission.
        for x in (
            select
                dept_no,
                ltrim(
                    sys_connect_by_path(emp_id, ','),
                    ','
                ) cbr
            from
                employee
            start with
                user_id = p_user_id
            connect by
                prior emp_id = manager_id
            order by
                1
        ) loop
            if x.dept_no = 6 then -- sales department no
          -- since sys connect by path shows emp_id concatenated we need to break it down in order to be able to query
                for xx in (
                    select
                        *
                    from
                        table ( str2tbl(x.cbr) )
                ) loop
                    for xxx in (
                        select
                            salesrep_id
                        from
                            salesrep
                        where
                            emp_id = xx.column_value
                    ) loop
                        l_record.salesrep_id := xxx.salesrep_id;
                        pipe row ( l_record );
                    end loop;
                end loop;

            else
                for xxx in (
                    select
                        salesrep_id
                    from
                        salesrep
                ) loop
                    l_record.salesrep_id := xxx.salesrep_id;
                    pipe row ( l_record );
                end loop;
            end if;
        end loop;
    end get_sales_rep_tree;

    function get_sales_rep_email (
        p_salesrep_id in number
    ) return varchar2 is
        l_email varchar2(255);
    begin

     -- There is a condition where the salesrep's either should see their commissions only or their managers
     -- when viewing the sales commission. If outside of sales organization then they should be able
     -- to see everyone's commission.
        for x in (
            select
                dept_no,
                manager_id,
                salesrep_id
            from
                employee a,
                salesrep b
            where
                    a.emp_id = b.emp_id
                and nvl(a.term_date, sysdate) >= sysdate
            start with
                b.salesrep_id = p_salesrep_id
            connect by
                prior a.emp_id = a.manager_id
            order by
                1
        ) loop
            if x.dept_no = 6 then -- sales department no
          -- since sys connect by path shows emp_id concatenated we need to break it down in order to be able to query

                for xxx in (
                    select
                        a.salesrep_id,
                        a.name,
                        b.email
                    from
                        salesrep a,
                        employee b
                    where
                            a.emp_id = x.manager_id
                        and a.emp_id = b.emp_id
                ) loop
                    l_email := xxx.email;
                end loop;

            end if;
        end loop;

        return l_email;
    end get_sales_rep_email;

    function is_plan_doc_only (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return varchar2 is
        l_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                plan_docs_flag
            from
                ben_plan_enrollment_setup
            where
                    product_type = p_product_type
                and entrp_id = p_entrp_id
                and plan_start_date <= p_start_date
                and plan_end_date >= p_end_date
        ) loop
            l_flag := x.plan_docs_flag;
            if l_flag = 'Y' then
                return l_flag;
            end if;
        end loop;

        return l_flag;
    end is_plan_doc_only;
  /* PROCEDURE calc_hrafsa_broker_comm(p_start_date IN DATE,p_end_date IN DATE,p_user_id IN NUMBER)
     IS
     BEGIN

         FOR X IN (   SELECT BROKER_ID, BROKER_LIC, ENTRP_ID
               , COUNT(EE_ACC_ID) NO_OF_EMPLOYEES
               , PRODUCT_TYPE
               , ACC_ID, REG_DATE
          FROM (  SELECT s.BROKER_ID
               , NVL(BROKER_LIC , 'SK'||s.BROKER_ID) BROKER_LIC
               , S.ENTRP_ID
               , S.ACC_ID
               , A.ACC_ID EE_ACC_ID
               , s.reg_date
               , CASE WHEN COUNT(A.PLAN_TYPE) > 3 THEN 'FSA_BUNDLE' ELSE B.PRODUCT_TYPE END PRODUCT_TYPE
                FROM  FSA_HRA_EMPLOYEES_V a ,ben_plan_enrollment_setup b,account s,BROKER BR
                 WHERE a.ENTRP_ID = b.entrp_id
                 AND a.entrp_id   = s.entrp_id
                 AND a.PLAN_START_DATE = b.plan_start_date
                 AND a.PLAN_TYPE = b.plan_type
                 AND s.account_type IN ('HRA', 'FSA')
                 AND s.reg_date BETWEEN P_START_DATE AND P_END_DATE
                 AND B.PLAN_END_DATE > SYSDATE
                 AND A.STATUS IN ('A','I')
                 AND S.BROKER_ID=BR.BROKER_ID
                 AND NVL(BR.BROKER_RATE,0) > 0
                 group by s.BROKER_ID  , BROKER_LIC , S.ENTRP_ID,s.reg_date
               , S.ACC_ID , A.ACC_ID, B.PRODUCT_TYPE) GROUP BY BROKER_ID, BROKER_LIC,ACC_ID, ENTRP_ID
               , PRODUCT_TYPE,reg_date )
        LOOP

           INSERT INTO BROKER_COMMISSION_REGISTER
           ( BROKER_ID
            ,BROKER_LIC
            ,ENTRP_ID
            ,ACC_ID
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,ACCOUNT_TYPE
            ,NO_OF_EMPLOYEES
            ,PAY_DATE
            ,ACCOUNT_CATEGORY)
            VALUES (X.BROKER_ID,X.BROKER_LIC,X.ENTRP_ID,X.ACC_ID
               , SYSDATE
               , -1
               , SYSDATE
               , -1
               , X.PRODUCT_TYPE
               , X.NO_OF_EMPLOYEES
               , x.reg_date
               , 'NEW');
       END LOOP;

         FOR X IN (   SELECT BROKER_ID, BROKER_LIC, ENTRP_ID
               , COUNT(EE_ACC_ID) NO_OF_EMPLOYEES
               , PRODUCT_TYPE
               , ACC_ID
               , PLAN_START_DATE
          FROM (  SELECT s.BROKER_ID
               , NVL(BROKER_LIC , 'SK'||s.BROKER_ID) BROKER_LIC
               , S.ENTRP_ID
               , S.ACC_ID
               , A.ACC_ID EE_ACC_ID
               , B.PLAN_START_DATE
               , CASE WHEN COUNT(A.PLAN_TYPE) > 3 THEN 'FSA_BUNDLE' ELSE B.PRODUCT_TYPE END PRODUCT_TYPE
                FROM  FSA_HRA_EMPLOYEES_V a ,ben_plan_enrollment_setup b,account s,BROKER BR
                 WHERE a.ENTRP_ID = b.entrp_id
                 AND a.entrp_id   = s.entrp_id
                 AND a.PLAN_START_DATE = b.plan_start_date
                 AND a.PLAN_TYPE = b.plan_type
                 AND s.account_type IN ('HRA', 'FSA')
                 AND s.reg_date < P_START_DATE
                 and B.RENEWAL_FLAG = 'Y'
                 AND B.PLAN_START_DATE BETWEEN P_START_DATE AND P_END_DATE
                 AND B.PLAN_END_DATE > SYSDATE
                 AND A.STATUS IN ('A','I')
                 AND S.BROKER_ID=BR.BROKER_ID
                 group by s.BROKER_ID  , BROKER_LIC , S.ENTRP_ID,B.PLAN_START_DATE
               , S.ACC_ID , A.ACC_ID, B.PRODUCT_TYPE) GROUP BY BROKER_ID, BROKER_LIC,ACC_ID, ENTRP_ID
               , PRODUCT_TYPE,PLAN_START_DATE )
        LOOP

           INSERT INTO BROKER_COMMISSION_REGISTER
           (      BROKER_ID
            ,BROKER_LIC
            ,ENTRP_ID
            ,ACC_ID
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,ACCOUNT_TYPE
            ,NO_OF_EMPLOYEES
            ,ACCOUNT_CATEGORY
            ,pay_date)
            VALUES (X.BROKER_ID,X.BROKER_LIC,X.ENTRP_ID,X.ACC_ID
               , SYSDATE
               , -1
               , SYSDATE
               , -1
               , X.PRODUCT_TYPE
               , X.NO_OF_EMPLOYEES
               , 'RENEWAL',x.PLAN_START_DATE);
       END LOOP;

    --
       UPDATE BROKER_COMMISSION_REGISTER A
        SET    BROKER_RATE = ( SELECT COMM_AMOUNT from SALES_COMM_RATES B
              WHERE A.ACCOUNT_TYPE = B.ACCOUNT_TYPE
              AND B.END_DATE IS NULL
              AND B.ACCOUNT_CATEGORY = A.ACCOUNT_CATEGORY
              AND B.ENTITY_TYPE = 'BROKER'
              AND B.COMM_METHOD = 'AMOUNT')
        WHERE  ACCOUNT_TYPE IN ('HRA','FSA')
        AND    BROKER_RATE IS NULL;

        UPDATE BROKER_COMMISSION_REGISTER A
        SET    BROKER_RATE = ( SELECT COMM_AMOUNT from SALES_COMM_RATES B
              WHERE A.ACCOUNT_TYPE = B.ACCOUNT_TYPE
              AND B.END_DATE IS NULL
              AND B.ACCOUNT_CATEGORY = A.ACCOUNT_CATEGORY
              AND B.ENTITY_TYPE = 'BROKER'
              AND B.COMM_METHOD = 'AMOUNT_RANGE'
              AND A.NO_OF_EMPLOYEES BETWEEN B.MIN_RANGE AND B.MAX_RANGE)
        WHERE  ACCOUNT_TYPE IN ('HRA','FSA')
        AND    BROKER_RATE IS NULL;

    END calc_hrafsa_broker_comm;*/
   --- New Broker Commission for FSA/HRA Effective July-- 
    procedure calc_hrafsa_broker_comm (
        p_start_date in date,
        p_end_date   in date,
        p_user_id    in number
    ) is
    begin
        for x in (
            select
                broker_id,
                broker_lic,
                broker_name,
                invoice_id,
                employer_name,
                account_number,
                acc_id,
                account_type,
                amount,
                period_start_date,
                period_end_date
            from
                (
                    select
                        b.broker_id,
                        b.broker_lic,
                        pc_broker.get_broker_name(b.broker_id) broker_name,
                        a.invoice_id,
                        pc_entrp.get_entrp_name(c.entity_id)   employer_name,
                        l.acc_num                              account_number,
                        l.acc_id,
                        a.account_type,
                        a.amount                               amount,
                        a.period_start_date,
                        a.period_end_date
                    from
                        monthly_new_rev_report a,
                        broker                 b,
                        ar_invoice             c,
                        account                l
                    where
                            c.invoice_id = a.invoice_id
                        and c.acc_id = l.acc_id
                        and l.broker_id = b.broker_id
                        and a.reason_code in ( 43, 44, 89 )
                        and a.period_start_date between p_start_date and p_end_date
                        and a.account_type in ( 'FSA', 'HRA' )
                )
        ) loop
            insert into broker_commission_register (
                broker_id,
                broker_lic,
                entrp_id
   --         ,NAME
                ,
                acc_id,
                account_type,
                amount,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                pay_date
         --  ,PERIOD_END_DATE
                ,
                account_category
            ) values ( x.broker_id,
                       x.broker_lic,
                       x.invoice_id,
                       x.acc_id,
                       x.account_type,
                       x.amount,
                       sysdate,
                       - 1,
                       sysdate,
                       - 1,
                       x.period_start_date
           --    ,X.PERIOD_END_DATE
                       ,
                       'NEW' );

        end loop;

        for x in (
            select
                broker_id,
                broker_lic,
                broker_name,
                invoice_id,
                employer_name,
                account_number,
                acc_id,
                account_type,
                amount,
                period_start_date,
                period_end_date
            from
                (
                    select
                        b.broker_id,
                        b.broker_lic,
                        pc_broker.get_broker_name(b.broker_id) broker_name,
                        a.invoice_id,
                        pc_entrp.get_entrp_name(c.entity_id)   employer_name,
                        l.acc_num                              account_number,
                        l.acc_id,
                        a.account_type,
                        a.amount                               amount,
                        a.period_start_date,
                        a.period_end_date
                    from
                        monthly_renewal_rev_report a,
                        broker                     b,
                        ar_invoice                 c,
                        account                    l,
                        ar_invoice_lines           ar
                    where
                            c.invoice_id = a.invoice_id
                        and c.acc_id = l.acc_id
                        and l.broker_id = b.broker_id
                        and a.invoice_id = ar.invoice_id
                        and ar.rate_code in ( 45, 46, 89 )
                        and a.period_start_date between p_start_date and p_end_date
                        and a.account_type in ( 'FSA', 'HRA' )
                )
        ) loop
            insert into broker_commission_register (
                broker_id,
                broker_lic,
                entrp_id
          --  ,NAME
                ,
                acc_id,
                account_type,
                amount,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                pay_date
          -- ,PERIOD_END_DATE
                ,
                account_category
            ) values ( x.broker_id,
                       x.broker_lic,
                       x.invoice_id,
                       x.acc_id,
                       x.account_type,
                       x.amount,
                       sysdate,
                       - 1,
                       sysdate,
                       - 1,
                       x.period_start_date
         --      ,X.PERIOD_END_DATE
                       ,
                       'RENEWAL' );

        end loop;

    --
        update broker_commission_register a
        set
            broker_rate = (
                select
                    comm_perc
                from
                    sales_comm_rates b
                where
                        a.account_type = b.account_type
                    and b.end_date is null
                    and b.account_category = a.account_category
                    and b.entity_type = 'BROKER'
                    and b.comm_method = 'PERCENTAGE'
            )
        where
            account_type in ( 'HRA', 'FSA' )
            and broker_rate is null;

    end calc_hrafsa_broker_comm;

    procedure run_broker_commission is
    begin
        for x in (
            select
                *
            from
                (
                    select
                        rownum rn,
                        add_months(
                            trunc(sysdate, 'yyyy'),
                            rownum * 3
                        )      period_date,
                        add_months(
                            trunc(sysdate, 'yyyy'),
                            (rownum - 1) * 3
                        )      period_start_date,
                        add_months(
                            trunc(sysdate, 'yyyy'),
                            rownum * 3
                        ) - 1  period_end_date
                    from
                        all_objects
                    where
                        rownum <= 4
                )
            where
                trunc(period_date) = trunc(sysdate)
        ) loop
            calc_hrafsa_broker_comm(x.period_start_date, x.period_end_date, 0);
        end loop;
    end run_broker_commission;
-- Commented Broker Commission for HSA by SK Effective 07/01--
    function get_broker_commission (
        p_account_type in varchar2,
        p_broker_id    in number,
        p_start_date   in varchar2,
        p_end_date     in varchar2
    ) return broker_comm_t
        pipelined
        deterministic
    is
        l_comm_amt varchar2(30);
        l_record   broker_comm_row;
    begin
        pc_log.log_error('get_broker_commission:P_ACCOUNT_TYPE', p_account_type);
        if p_account_type = 'HSA' then
            for x in (
                select
                    b.broker_id,
                    b.broker_lic,
                    b.broker_rate,
                    c.pers_id,
                    c.entrp_id,
                    round(
                        sum(amount),
                        2
                    )        fees,
                    round(sum(amount) *(broker_rate / 100),
                          2) commission
                from
                    broker_commission_register b,
                    person                     c
                where
                        b.pers_id = c.pers_id
                    and b.broker_id = p_broker_id
                    and b.pay_date >= to_date(p_start_date)
                    and b.pay_date <= to_date(p_end_date)
                    and b.account_type = 'HSA'
                group by
                    c.pers_id,
                    c.entrp_id,
                    broker_id,
                    broker_lic,
                    broker_rate
                order by
                    entrp_id
            ) loop
                l_record.broker_id := x.broker_id;
                l_record.broker_lic := x.broker_lic;
                l_record.broker_rate := x.broker_rate;
                l_record.pers_id := x.pers_id;
                l_record.entrp_id := x.entrp_id;
                l_record.fees := x.fees;
                l_record.commission := x.commission;
                l_record.person_name := pc_person.get_person_name(x.pers_id);
                l_record.entrp_name := pc_entrp.get_entrp_name(x.entrp_id);
                pipe row ( l_record );
            end loop;

        else
            for x in (
                select
                    b.broker_id,
                    b.broker_lic,
                    b.broker_rate,
				-- b.entrp_id,-- SK UPDATED ON 10/28/2021
                    e.entrp_id,
                    b.account_category,
                    round(
                        sum(no_of_employees),
                        2
                    )        no_of_employees,
				-- round(SUM(broker_rate),2) BROKER_RATE -- SK Made the change on 10/28/2021 to reflect new HRA/FSA Commission
                    round(sum(amount) *(broker_rate / 100),
                          2) commission -- SK Made the change on 10/28/2021 to reflect new HRA/FSA Commission
                from
                    broker_commission_register b,
                    account                    e
                where
                        b.broker_id = p_broker_id
                    and b.acc_id = e.acc_id
                    and b.pay_date >= to_date(p_start_date)
                    and b.pay_date <= to_date(p_end_date)
                    and b.account_type = p_account_type
                group by
                    e.entrp_id,
                    b.broker_id,
                    b.broker_lic,
                    b.broker_rate,
                    b.account_category
                order by
                    e.entrp_id
            ) loop
                l_record.broker_id := x.broker_id;
                l_record.broker_lic := x.broker_lic;
                l_record.broker_rate := x.broker_rate;
                l_record.entrp_id := x.entrp_id;
                l_record.no_of_employees := x.no_of_employees;
                l_record.account_category := x.account_category;

            --L_RECORD.COMMISSION := x.BROKER_RATE;-- SK Made the change on 10/28/2021 to reflect new HRA/FSA Commission
                l_record.commission := x.commission;-- SK Made the change on 10/28/2021 to reflect new HRA/FSA Commission
                l_record.entrp_name := pc_entrp.get_entrp_name(x.entrp_id);
                pipe row ( l_record );
            end loop;
        end if;

    end get_broker_commission;

    function get_account_type (
        p_broker_id in number
    ) return account_type_t
        pipelined
        deterministic
    is
        l_record account_type_row;
    begin
        for x in (
            select distinct
                account_type
            from
                broker_commission_register
            where
                    broker_id = p_broker_id
                and account_type in ( 'HRA', 'FSA', 'HSA' )
        ) loop
            l_record.account_type := x.account_type;
            l_record.meaning := pc_lookups.get_account_type(x.account_type);
            pipe row ( l_record );
        end loop;
    end get_account_type;

    procedure auto_save_commission is
    begin
        for x in (
            select
                *
            from
                account_type
        ) loop
            pc_commission.save_commissions(x.lookup_code,
                                           trunc(trunc(sysdate, 'MM') - 1,
                                                 'MM'),
                                           trunc(sysdate, 'MM') - 1,
                                           0);
        end loop;
    end auto_save_commission;

    procedure sales_new_revenue_report is
    begin
        update sales_new_revenue_report
        set
            ytd_revenue_amount = (
                select
                    sum(revenue_amount)
                from
                    (
                        select
                            pc_account.get_salesrep_name(a.salesrep_id) sd,
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB', 'FMLA',
                                                         'LSA' )
                                     and b.rate_code = 89
                                     and exists (
                                    select
                                        *
                                    from
                                        ar_invoice_lines
                                    where
                                            invoice_id = b.invoice_id
                                        and rate_code in ( 183, 184 )
                                ) then
                                    b.total_line_amount
                                else
                                    0
                            end                                         monthly_discount,
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB', 'FMLA',
                                                         'LSA' )
                                     and b.rate_code = 264
                                     or ( b.rate_code in ( 89, 266 )
                                          and exists (
                                    select
                                        *
                                    from
                                        ar_invoice_lines
                                    where
                                            invoice_id = b.invoice_id
                                        and rate_code in ( 1, 100, 43, 44 )
                                ) ) then
                                    b.total_line_amount
                                else
                                    0
                            end                                         setup_discount,
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB', 'FMLA',
                                                         'LSA' )
                                     and c.reason_code in ( 1, 100, 43, 44 ) then
                                    b.total_line_amount
                                else
                                    0
                            end                                         setup,
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and exists (
                                    select
                                        *
                                    from
                                        ar_invoice_lines
                                    where
                                            invoice_id = b.invoice_id
                                        and rate_code in ( 1, 100, 43, 44, 184 )
                                ) then
                                    b.total_line_amount
                                else
                                    0
                            end                                         setup_optional,
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and not exists (
                                    select
                                        *
                                    from
                                        ar_invoice_lines
                                    where
                                            invoice_id = b.invoice_id
                                        and rate_code in ( 1, 100, 43, 44, 184 )
                                )
                                     and ( greatest(
                                    trunc(d.reg_date),
                                    trunc(d.start_date)
                                ) >= add_months(
                                    trunc(a.start_date),
                                    -11
                                ) ) then
                                    b.total_line_amount
                                else
                                    0
                            end                                         setup_optional_standalone,
                            (
                                case
                                    when c.reason_code = 184 then
                                        b.total_line_amount
                                    when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                             'ACA', 'FSA', 'HRA' )
                                         and c.reason_code in ( 2, 35, 31, 33, 67,
                                                                34, 68, 36, 39, 38,
                                                                37, 32, 40 )
                                         and ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) >= add_months(
                                        trunc(a.start_date),
                                        -11
                                    ) ) then
                                        b.total_line_amount
                                    when d.account_type in ( 'FMLA', 'RB' )
                                         and c.reason_code = 2
                                         and ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) >= add_months(
                                        trunc(a.start_date),
                                        -11
                                    ) ) then
                                        b.total_line_amount
                                    else
                                        0
                                end
                            )                                           monthly,
                            case
                                when b.rate_code = 264
                                     or ( b.rate_code in ( 89, 266 )
                                          and exists (
                                        select
                                            *
                                        from
                                            ar_invoice_lines
                                        where
                                                invoice_id = b.invoice_id
                                            and rate_code in ( 1, 100, 43, 44, 184 )
                                    ) ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            +
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and exists (
                                        select
                                            *
                                        from
                                            ar_invoice_lines
                                        where
                                                invoice_id = b.invoice_id
                                            and rate_code in ( 1, 100, 43, 44, 184 )
                                    ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            +
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and not exists (
                                        select
                                            *
                                        from
                                            ar_invoice_lines
                                        where
                                                invoice_id = b.invoice_id
                                            and rate_code in ( 1, 100, 43, 44, 184 )
                                    )
                                     and ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) >= add_months(
                                        trunc(a.start_date),
                                        -11
                                    ) ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            +
                            case
                                when c.reason_code in ( 1, 100, 43, 44 ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            + (
                                case
                                    when c.reason_code = 184 then
                                        b.total_line_amount
                                    when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                             'ACA', 'FSA', 'HRA' )
                                         and c.reason_code in ( 2, 35, 31, 33, 67,
                                                                34, 68, 36, 39, 38,
                                                                37, 32, 40 )
                                         and ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) >= add_months(
                                        trunc(a.start_date),
                                        -11
                                    ) ) then
                                        b.total_line_amount
                                    when d.account_type in ( 'FMLA', 'RB' )
                                         and c.reason_code = 2
                                         and ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) >= add_months(
                                        trunc(a.start_date),
                                        -11
                                    ) ) then
                                        b.total_line_amount
                                    else
                                        0
                                end
                            )                                           as revenue_amount,
                            a.salesrep_id                               as details
                        from
                            ar_invoice       a,
                            ar_invoice_lines b,
                            pay_reason       c,
                            account          d
                        where
                                a.invoice_id = b.invoice_id
                            and ( trunc(a.approved_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                                  and trunc(a.start_date) <= trunc(sysdate)
                                  or trunc(a.start_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                                  and trunc(a.approved_date) < trunc(sysdate, 'YYYY') )
                            and a.acc_id = d.acc_id
                            and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                    'FSA', 'HRA', 'ACA', 'FMLA', 'RB' )
                            and a.invoice_reason = 'FEE'
                            and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                                  and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                            and b.rate_code = to_char(c.reason_code)
--AND (A.SALESREP_ID IS NOT NULL 
--and a.salesrep_id NOT IN (0,501,541,961))
                            and a.status <> 'CANCELLED'
                        union all
                        select
                            pc_account.get_salesrep_name(d.salesrep_id) sd,
                            0                                           as monthly_discount,
                            0                                           as setup_discount,
                            0                                           as setup_optional,
                            0                                           as setup_optional_standalone,
                            case
                                when p.reason_code = 100 then
                                    p.amount
                                else
                                    0
                            end                                         setup,
                            case
                                when p.reason_code = 2 then
                                    p.amount
                                else
                                    0
                            end                                         monthly,
                            case
                                when p.reason_code = 100 then
                                        p.amount
                                else
                                    0
                            end
                            + (
                                case
                                    when p.reason_code = 2 then
                                        p.amount
                                    else
                                        0
                                end
                            )                                           as revenue_amount,
                            d.salesrep_id                               as details
                        from
                            person  a,
                            account d,
                            payment p,
                            account er
                        where
                            d.account_type in ( 'HSA', 'LSA' )
                /*AND   d.START_DATE  between add_months(trunc(sysdate, 'mm'), -12) and trunc(sysdate, 'mm')*/
                            and d.pers_id = a.pers_id
                            and p.acc_id = d.acc_id
                            and a.entrp_id = er.entrp_id
                            and a.entrp_id is not null
                            and trunc(p.pay_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                            and p.reason_code in ( 2, 100 ) 
            --WHERE NVL(FIRST_PAYMENT_DATE ,FIRST_fEE_DATE) >= P_EFFECTIVE_dATE
           -- WHERE FIRST_PAYMENT_DATE  >= P_EFFECTIVE_dATE
                            and months_between(pay_date, er.start_date) <= 12
                    )
            ),
            last_update_date = trunc(sysdate);

    end sales_new_revenue_report;

/* PROCEDURE SALES_RENEWAL_REVENUE_REPORT

IS
BEGIN

UPDATE SALES_RENEWAL_REVENUE_REPORT
                SET YTD_REVENUE_AMOUNT=
(SELECT SUM(REVENUE_AMOUNT) FROM
(
 SELECT 
    D.ACCOUNT_TYPE
   ,case when D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','RB','FMLA')
   and (B.RATE_CODE =265 OR  ( b.Rate_code IN(89,266)  and exists (select * from ar_invoice_lines where invoice_id=
 b.invoice_id and rate_code IN (30,45,46,182)))) THEN B.TOTAL_LINE_AMOUNT ELSE 0  END "DISCOUNT"
,Case when D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','RB','FMLA')and C.Reason_code IN  (30,45,46)
THEN B.TOTAL_LINE_AMOUNT ELSE 0  END "RENEWAL"
   ,case when D.ACCOUNT_TYPE ='COBRA' AND b.Rate_code IN(54,55,86)  and exists (select * from ar_invoice_lines where invoice_id=
 b.invoice_id and rate_code IN (30,45,46,182)) THEN B.TOTAL_LINE_AMOUNT ELSE 0  END "RENEWA_OPTIONAL"
,Case when D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','RB')and c.reason_code =182 
  OR (GREATEST (TRUNC(D.Reg_Date),TRUNC(D.Start_Date)) < add_months(A.START_DATE,-12) and c.reason_code IN  (2,35,31,33,67,34,68,36,39,38,37,32,40))
    OR (D.ACCOUNT_TYPE='FMLA' AND
    (GREATEST (TRUNC(D.Reg_Date),TRUNC(D.Start_Date)) < add_months(A.START_DATE,-11) and c.reason_code=2)) THEN B.TOTAL_LINE_AMOUNT ELSE 0 END "MONTHLY"
        
         , case when D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','RB')AND (B.RATE_CODE =265
         OR (b.Rate_code IN(89,266)  and exists (select * from ar_invoice_lines where invoice_id=
 b.invoice_id and rate_code IN (30,45,46)))) THEN B.TOTAL_LINE_AMOUNT ELSE 0  END+ 
 case when D.ACCOUNT_TYPE ='COBRA' AND b.Rate_code IN(54,55,86)  and exists (select * from ar_invoice_lines where invoice_id=
 b.invoice_id and rate_code IN (30,45,46,182)) THEN B.TOTAL_LINE_AMOUNT ELSE 0 END +
 Case when D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','RB') and C.Reason_code IN (30,45,46)
 THEN B.TOTAL_LINE_AMOUNT ELSE 0  END+
 (Case when D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','RB')and c.reason_code =182 
  OR (GREATEST (TRUNC(D.Reg_Date),TRUNC(D.Start_Date)) < add_months(A.START_DATE,-12) and c.reason_code IN  (2,35,31,33,67,34,68,36,39,38,37,32,40))
    OR (D.ACCOUNT_TYPE='FMLA' AND
    (GREATEST (TRUNC(D.Reg_Date),TRUNC(D.Start_Date)) < add_months(A.START_DATE,-11) and c.reason_code=2))
    THEN B.TOTAL_LINE_AMOUNT ELSE 0 END) AS "REVENUE_AMOUNT"
FROM   AR_INVOICE A, AR_INVOICE_LINES B,PAY_REASON C, ACCOUNT D
WHERE  A.INVOICE_ID = B.INVOICE_ID
AND  (TRUNC(A.APPROVED_DATE) BETWEEN TRUNC(SYSDATE,'YYYY') AND TRUNC(SYSDATE)
AND TRUNC(A.START_DATE) <= SYSDATE
OR
TRUNC(A.START_DATE) BETWEEN   TRUNC(SYSDATE,'YYYY') AND TRUNC(SYSDATE)
AND TRUNC(A.APPROVED_DATE) < TRUNC(SYSDATE,'YYYY'))
AND    A.ACC_ID = D.ACC_ID
--AND D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','FMLA','RB')
AND A.INVOICE_REASON='FEE'
AND (A.STATUS  in ('POSTED','PARTIALLY_POSTED','PROCESSED')
AND B.STATUS IN ('POSTED','PARTIALLY_POSTED','PROCESSED','ADJUSTMENT'))
AND    B.RATE_CODE = TO_CHAR(C.REASON_CODE)
--ENABLE THIS FOR FSA/HRA
AND    A.STATUS <>'CANCELLED'
UNION ALL
SELECT
D.ACCOUNT_TYPE,
      0 AS "DISCOUNT"
       ,Case when  P.Reason_code =100   THEN P.AMOUNT ELSE 0  END "RENEWAL"
       ,0 AS "RENEWAL_OPTIONAL"
  ,case  when   P.Reason_code =2   THEN P.AMOUNT ELSE 0  END "MONTHLY" 
  , Case when  P.Reason_code =100 THEN P.AMOUNT ELSE 0  END+
    (case when  P.Reason_code =2 THEN P.AMOUNT ELSE 0  END) AS "REVENUE_AMOUNT"    
                           FROM PERSON A
                      ,ACCOUNT d
                      ,PAYMENT P
                      ,account ER
                 WHERE   d.ACCOUNT_TYPE = 'HSA'
                  AND   d.PERS_ID = A.PERS_ID
                  AND   P.ACC_ID = d.ACC_ID
                 and A.ENTRP_ID=ER.ENTRP_ID
                  AND   A.ENTRP_ID IS NOT NULL
   AND   TRUNC(P.PAY_DATE) BETWEEN TRUNC(SYSDATE,'YYYY') AND TRUNC(SYSDATE)

                -- AND   ACCOUNT.AM_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                  AND   P.REASON_CODE in (2,100) 
            --WHERE NVL(FIRST_PAYMENT_DATE ,FIRST_fEE_DATE) >= P_EFFECTIVE_dATE
           -- WHERE FIRST_PAYMENT_DATE  >= P_EFFECTIVE_dATE
            and   months_between (pay_Date,ER.START_DATE) > 12
          
    UNION ALL
    SELECT
                      D.ACCOUNT_TYPE,
                      0 AS "DISCOUNT",
       Case when  P.Reason_code =100   THEN P.AMOUNT ELSE 0  END "RENEWAL"
         ,0 AS "RENEWAL_OPTIONAL"
  ,case  when   P.Reason_code =2   THEN P.AMOUNT ELSE 0  END "MONTHLY" 
  , Case when  P.Reason_code =100 THEN P.AMOUNT ELSE 0  END+
    (case when  P.Reason_code =2 THEN P.AMOUNT ELSE 0  END) AS "REVENUE_AMOUNT"   
                           FROM PERSON A
                      ,ACCOUNT d
                      ,PAYMENT P
                      WHERE   d.ACCOUNT_TYPE = 'HSA'
                  AND   d.PERS_ID = A.PERS_ID
                  AND   P.ACC_ID = d.ACC_ID
                 -- AND A.ENTRP_ID =ER.ENTRP_ID   
                  AND   A.ENTRP_ID IS  NULL
               AND   TRUNC(P.PAY_DATE) BETWEEN TRUNC(SYSDATE,'YYYY') AND TRUNC(SYSDATE)
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                  AND   P.REASON_CODE in (2,100))
),
                   LAST_UPDATE_DATE= TRUNC(SYSDATE);
        
END SALES_RENEWAL_REVENUE_REPORT;
*/

    procedure sales_renewal_revenue_report is
    begin
        update sales_renewal_revenue_report
        set
            ytd_revenue_amount = (
                select
                    sum(revenue_amount)
                from
                    (
                        select
                            d.account_type,
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
                                     and b.rate_code = 265
                                     or ( b.rate_code in ( 266, 89 )
                                          and exists (
                                    select
                                        *
                                    from
                                        ar_invoice_lines
                                    where
                                            invoice_id = b.invoice_id
                                        and rate_code in ( 30, 45, 46, 182 )
                                ) ) then
                                    b.total_line_amount
                                else
                                    0
                            end discount,
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
                                     and c.reason_code in ( 30, 45, 46 ) then
                                    b.total_line_amount
                                else
                                    0
                            end renewal,
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and exists (
                                    select
                                        *
                                    from
                                        ar_invoice_lines
                                    where
                                            invoice_id = b.invoice_id
                                        and rate_code in ( 30, 45, 46, 182 )
                                ) then
                                    b.total_line_amount
                                else
                                    0
                            end renewal_optional,
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and not exists (
                                    select
                                        *
                                    from
                                        ar_invoice_lines
                                    where
                                            invoice_id = b.invoice_id
                                        and rate_code in ( 30, 45, 46, 182 )
                                )
                                     and ( greatest(
                                    trunc(d.reg_date),
                                    trunc(d.start_date)
                                ) < add_months(a.start_date, -11) ) then
                                    b.total_line_amount
                                else
                                    0
                            end renewal_optional_standalone,
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA' )
                                     and c.reason_code = 182
                                     or ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) < add_months(a.start_date, -11)
                                          and c.reason_code in ( 2, 35, 31, 33, 67,
                                                                 34, 68, 36, 39, 38,
                                                                 37, 32, 40 ) )
                                     or ( d.account_type in ( 'FMLA', 'RB' )
                                          and ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) < add_months(a.start_date, -11)
                                                and c.reason_code = 2 ) ) then
                                    b.total_line_amount
                                else
                                    0
                            end monthly,
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB' )
                                     and b.rate_code = 265
                                     or ( b.rate_code in ( 89, 266 )
                                          and exists (
                                        select
                                            *
                                        from
                                            ar_invoice_lines
                                        where
                                                invoice_id = b.invoice_id
                                            and rate_code in ( 30, 45, 46 )
                                    ) ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            +
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and exists (
                                        select
                                            *
                                        from
                                            ar_invoice_lines
                                        where
                                                invoice_id = b.invoice_id
                                            and rate_code in ( 30, 45, 46, 182 )
                                    ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            +
                            case
                                when d.account_type = 'COBRA'
                                     and b.rate_code in ( 54, 55, 86 )
                                     and not exists (
                                        select
                                            *
                                        from
                                            ar_invoice_lines
                                        where
                                                invoice_id = b.invoice_id
                                            and rate_code in ( 30, 45, 46, 182 )
                                    )
                                     and ( greatest(
                                        trunc(d.reg_date),
                                        trunc(d.start_date)
                                    ) < add_months(a.start_date, -11) ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            +
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB' )
                                     and c.reason_code in ( 30, 45, 46 ) then
                                        b.total_line_amount
                                else
                                    0
                            end
                            + (
                                case
                                    when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                             'ACA', 'FSA', 'HRA' )
                                         and c.reason_code = 182
                                         or ( greatest(
                                            trunc(d.reg_date),
                                            trunc(d.start_date)
                                        ) < add_months(a.start_date, -11)
                                              and c.reason_code in ( 2, 35, 31, 33, 67,
                                                                     34, 68, 36, 39, 38,
                                                                     37, 32, 40 ) )
                                         or ( d.account_type in ( 'FMLA', 'RB' )
                                              and ( greatest(
                                            trunc(d.reg_date),
                                            trunc(d.start_date)
                                        ) < add_months(a.start_date, -11)
                                                    and c.reason_code = 2 ) ) then
                                        b.total_line_amount
                                    else
                                        0
                                end
                            )   as revenue_amount
                        from
                            ar_invoice       a,
                            ar_invoice_lines b,
                            pay_reason       c,
                            account          d
                        where
                                a.invoice_id = b.invoice_id
                            and ( trunc(a.approved_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                                  and trunc(a.start_date) <= sysdate
                                  or trunc(a.start_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                                  and trunc(a.approved_date) < trunc(sysdate, 'YYYY') )
                            and a.acc_id = d.acc_id
--AND D.ACCOUNT_TYPE IN('COBRA','ERISA_WRAP','POP','CMP','FORM_5500','ACA','FSA','HRA','FMLA','RB')
                            and a.invoice_reason = 'FEE'
                            and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                                  and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                            and b.rate_code = to_char(c.reason_code)
--ENABLE THIS FOR FSA/HRA
                            and a.status <> 'CANCELLED'

/*AND (A.am_id is not null
and a.am_id NOT IN (0,501,541,961))*/
                        union all
                        select
                            d.account_type,
                            0   as discount,
                            case
                                when p.reason_code = 100 then
                                    p.amount
                                else
                                    0
                            end renewal,
                            0   as renewal_optional,
                            0   as renewal_optional_stanadlone,
                            case
                                when p.reason_code = 2 then
                                    p.amount
                                else
                                    0
                            end monthly,
                            case
                                when p.reason_code = 100 then
                                        p.amount
                                else
                                    0
                            end
                            + (
                                case
                                    when p.reason_code = 2 then
                                        p.amount
                                    else
                                        0
                                end
                            )   as revenue_amount
                        from
                            person  a,
                            account d,
                            payment p,
                            account er
                        where
                            d.account_type in ( 'HSA', 'LSA' )
                /*AND   d.START_DATE  between add_months(trunc(sysdate, 'mm'), -12) and trunc(sysdate, 'mm')*/
                            and d.pers_id = a.pers_id
                            and p.acc_id = d.acc_id
                            and a.entrp_id = er.entrp_id
                            and a.entrp_id is not null
                            and trunc(p.pay_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                            and p.reason_code in ( 2, 100 )
                            and months_between(pay_date, er.start_date) > 12
                        union all
                        select
                            d.account_type,
                            0   as discount,
                            case
                                when p.reason_code = 100 then
                                    p.amount
                                else
                                    0
                            end renewal,
                            0   as renewal_optional,
                            0   as renewal_optional_stanadlone,
                            case
                                when p.reason_code = 2 then
                                    p.amount
                                else
                                    0
                            end monthly,
                            case
                                when p.reason_code = 100 then
                                        p.amount
                                else
                                    0
                            end
                            + (
                                case
                                    when p.reason_code = 2 then
                                        p.amount
                                    else
                                        0
                                end
                            )   as revenue_amount
                        from
                            person  a,
                            account d,
                            payment p
                        where
                                d.account_type = 'HSA'
                /*AND   d.START_DATE  between add_months(trunc(sysdate, 'mm'), -12) and trunc(sysdate, 'mm')*/
                            and d.pers_id = a.pers_id
                            and p.acc_id = d.acc_id
                 -- AND A.ENTRP_ID =ER.ENTRP_ID   
                            and a.entrp_id is null
                            and trunc(p.pay_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                            and p.reason_code in ( 2, 100 )
                    )
            ),
            last_update_date = trunc(sysdate);

    end sales_renewal_revenue_report;

    procedure sales_company_revenue_report is
    begin
        update sales_company_revenue_report
        set
            ytd_revenue_amount = (
                select
                    sum(total_line_amount)
                from
                    (
                        select
                            b.total_line_amount
      --,pc_account.GET_SALESREP_NAME(A.SALESREP_ID)"Account Manager",
                            ,
                            d.account_type
                        from
                            ar_invoice       a,
                            ar_invoice_lines b,
                            pay_reason       c,
                            account          d
                        where
                                a.invoice_id = b.invoice_id
                            and ( trunc(a.approved_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                                  and trunc(a.start_date) <= sysdate
                                  or trunc(a.start_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                                  and trunc(a.approved_date) < trunc(sysdate, 'YYYY') )
                            and a.acc_id = d.acc_id
                            and d.account_type in ( 'FSA', 'HRA', 'COBRA', 'ERISA_WRAP', 'FORM_5500',
                                                    'CMP', 'POP', 'ACA', 'FMLA', 'RB' )
                            and a.invoice_reason = 'FEE'
                            and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                                  and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                            and b.rate_code = to_char(c.reason_code)
                            and c.reason_code not in ( 1, 100, 43, 44, 184,
                                                       30, 45, 46, 182, 2,
                                                       35, 31, 33, 67, 34,
                                                       68, 36, 39, 38, 37,
                                                       32, 40, 54, 55, 86,
                                                       85, 89, 264, 265, 266,
                                                       267, 268 )
                            and a.status <> 'CANCELLED'
                        union all
                        select
                            p.amount,
                            d.account_type
                        from
                            person     a,
                            account    d,
                            payment    p,
                            pay_reason l
                        where
                                d.account_type = 'HSA'
                /*AND   d.START_DATE  between add_months(trunc(sysdate, 'mm'), -12) and trunc(sysdate, 'mm')*/
                            and d.pers_id = a.pers_id
                            and p.acc_id = d.acc_id
                            and p.reason_code = l.reason_code
                            and l.reason_type = 'FEE'
                 -- AND A.ENTRP_ID =ER.ENTRP_ID   
                  --AND   A.ENTRP_ID IS  NULL
                            and trunc(p.pay_date) between trunc(sysdate, 'YYYY') and trunc(sysdate)
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                            and p.reason_code not in ( 2, 100 )
                    )
            ),
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
            last_update_date = trunc(sysdate);

    end sales_company_revenue_report;

    function get_summ_salesrep_report_old (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return enrolled_row_t
        pipelined
        deterministic
    is
        l_record   enrolled_row;
        l_entrp_id number := 0;
    begin
        if p_account_type in ( 'FORM_5500', 'CMP' ) then --Removed POP from this list.09/30/2018
            for x in (
                select
                    a.salesrep_id,
                    'N' renewal,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    d.check_amount,
                    a.start_date,
                    broker_id,
                    d.invoice_id
                from
                    account           a,
                    employer_payments d
                where
                        a.account_type = p_account_type
                    and a.entrp_id = d.entrp_id
                    and d.reason_code = 1
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                            s.acc_num = a.acc_num
                    )
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := 'N';
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                l_record.invoice_id := x.invoice_id;
                pipe row ( l_record );
            end loop;
            --Ticket#3690. Add renewal Entry for FORM5500 and Compliance products
            for x in (
                select
                    a.salesrep_id,
                    'Y' renewal,
                    a.acc_num,
                    a.entrp_id,
                    d.reason_code,
                    a.acc_id,
                    d.check_amount,
                    a.start_date,
                    broker_id
                from
                    account           a,
                    employer_payments d
                where
                        a.account_type = p_account_type
                    and a.entrp_id = d.entrp_id
                    and d.reason_code = 30
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                            s.acc_num = a.acc_num
                    )
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                                s.acc_num = a.acc_num
                            and s.account_type = 'Renewal'
                            and s.creation_date >= p_start_date
                            and fee_paid > 0
                    )
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                pipe row ( l_record );
            end loop;
            --End of Ticket#3690
        elsif p_account_type = 'COBRA' then
            for x in (
                select
                    a.salesrep_id,
                    'N'                 renewal,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    a.start_date,
                    broker_id,
                    sum(d.check_amount) check_amount,
                    d.invoice_id
                from
                    account           a,
                    employer_payments d
                where
                        a.account_type = p_account_type
                    and a.entrp_id = d.entrp_id
                    and d.reason_code not in ( 11, 12, 19 )
                    and a.account_status = 1
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and exists (
                        select
                            *
                        from
                            employer_payments e
                        where
                                d.entrp_id = e.entrp_id
                            and e.reason_code = 1
                            and trunc(e.transaction_date) between p_start_date and p_end_date
                    )
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                            s.acc_num = a.acc_num
                    )
                group by
                    a.salesrep_id,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    a.start_date,
                    broker_id,
                    d.invoice_id
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                l_record.invoice_id := x.invoice_id;
                pipe row ( l_record );
            end loop;

            for x in (
                select
                    a.salesrep_id,
                    'Y'                 renewal,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    a.start_date,
                    broker_id,
                    sum(d.check_amount) check_amount,
                    d.invoice_id
                from
                    account           a,
                    employer_payments d
                where
                        a.account_type = p_account_type
                    and a.entrp_id = d.entrp_id
                    and d.reason_code not in ( 11, 12, 19 )
                    and a.account_status = 1
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and exists (
                        select
                            *
                        from
                            employer_payments e
                        where
                                d.entrp_id = e.entrp_id
                            and e.reason_code <> 1
                            and trunc(e.transaction_date) between p_start_date and p_end_date
                    )
                    and not exists (
                        select
                            *
                        from
                            employer_payments e
                        where
                                d.entrp_id = e.entrp_id
                            and e.reason_code in ( 1, 23 )
                            and trunc(e.transaction_date) between p_start_date and p_end_date
                    )
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                                s.acc_num = a.acc_num
                            and s.account_type = 'Renewal'
                            and s.creation_date >= p_start_date
                            and fee_paid > 0
                    )
                group by
                    a.salesrep_id,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    a.start_date,
                    broker_id,
                    d.invoice_id
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                l_record.invoice_id := x.invoice_id;
                pipe row ( l_record );
            end loop;

        elsif p_account_type = 'ERISA_WRAP' then
            for x in (
                select
                    a.salesrep_id,
                    'N' renewal,
                    a.acc_num,
                    a.entrp_id,
                    d.reason_code,
                    a.acc_id,
                    d.check_amount,
                    a.start_date,
                    broker_id
                from
                    account           a,
                    employer_payments d
                where
                        a.account_type = p_account_type
                    and a.entrp_id = d.entrp_id
                    and d.reason_code in ( 1, 30, 100 )
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                            s.acc_num = a.acc_num
                    )
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                pipe row ( l_record );
            end loop;

            for x in (
                select
                    a.salesrep_id,
                    'Y' renewal,
                    a.acc_num,
                    a.entrp_id,
                    d.reason_code,
                    a.acc_id,
                    d.check_amount,
                    a.start_date,
                    broker_id
                from
                    account           a,
                    employer_payments d
                where
                        a.account_type = p_account_type
                    and a.entrp_id = d.entrp_id
                    and d.reason_code = 30
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                            s.acc_num = a.acc_num
                    )
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                                s.acc_num = a.acc_num
                            and s.account_type = 'Renewal'
                            and s.creation_date >= p_start_date
                            and fee_paid > 0
                    )
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                pipe row ( l_record );
            end loop;

        elsif p_account_type = 'HSA' then
            for x in (
                select
                    account.acc_num,
                    account.salesrep_id,
                    pc_account.get_employer_status(person.entrp_id,
                                                   to_char(p_start_date, 'MM/DD/YYYY'),
                                                   to_char(p_end_date, 'MM/DD/YYYY')) status,
                    person.entrp_id,
                    account.acc_id,
                    to_char(account.start_date, 'MM/DD/YYYY')     start_date,
                    broker_id
                from
                    person,
                    account,
                    plans
                where
                        account.pers_id = person.pers_id
                    and account.salesrep_id is not null
                    and person.person_type <> 'BROKER'
                    and trunc(account.start_date) >= p_start_date
                    and trunc(account.start_date) <= p_end_date
                    and account.account_type = 'HSA'
                    and account.account_status in ( 1, 2 )
                    and account.plan_code = plans.plan_code
                    and plans.plan_sign = 'SHA'
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history b
                        where
                            account.acc_num = b.acc_num
                    )
            ) loop
                l_record.er_acc_num := pc_entrp.get_acc_num(x.entrp_id);
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.status;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.entrp_id := x.entrp_id;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.effective_date := x.start_date;
                l_record.broker_id := x.broker_id;
                pipe row ( l_record );
            end loop;
        elsif p_account_type in ( 'HRA', 'FSA' ) then
            for x in (
                select
                    a.salesrep_id,
                    decode(d.reason_code, 1, 'N', 30, 'Y') renewal,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    d.plan_type,
                    a.start_date,
                    broker_id,
                    sum(d.check_amount)                    check_amount
                from
                    account           a,
                    employer_payments d
                where
                        d.plan_type = p_account_type
                    and a.account_type in ( 'HRA', 'FSA' )
                    and a.entrp_id = d.entrp_id
                    and d.reason_code = 1
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                                s.acc_num = a.acc_num
                            and s.product_type = p_account_type
                    )
                group by
                    a.salesrep_id,
                    decode(d.reason_code, 1, 'N', 30, 'Y'),
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    a.start_date,
                    d.plan_type,
                    broker_id
                having
                    sum(check_amount) > 0
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.product_type := x.plan_type;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.plan_doc_flag := is_plan_doc_only(x.entrp_id, p_account_type, p_start_date, p_end_date);
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                pipe row ( l_record );
            end loop;

            for x in (
                select
                    a.salesrep_id,
                    decode(d.reason_code, 1, 'N', 30, 'Y') renewal,
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    d.plan_type,
                    a.start_date,
                    broker_id,
                    sum(d.check_amount)                    check_amount,
                    (
                        select
                            max(renewal_date)
                        from
                            ben_plan_enrollment_setup c
                        where
                                c.entrp_id = a.entrp_id
                            and c.product_type = p_account_type
                            and c.status <> 'R'
                    )                                      renewal_date
                from
                    account           a,
                    employer_payments d
                where
                        d.plan_type = p_account_type
                    and a.account_type in ( 'HRA', 'FSA' )
                    and a.entrp_id = d.entrp_id
                    and d.reason_code = 30
                    and trunc(d.transaction_date) between p_start_date and p_end_date
                    and not exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                                s.acc_num = a.acc_num
                            and period_start_date >= p_start_date
                            and period_end_date <= p_end_date
                            and fee_paid > 0
                    )
                    and exists (
                        select
                            *
                        from
                            sales_commission_history s
                        where
                            s.acc_num = a.acc_num
                    )
                group by
                    a.salesrep_id,
                    decode(d.reason_code, 1, 'N', 30, 'Y'),
                    a.acc_num,
                    a.entrp_id,
                    a.acc_id,
                    a.start_date,
                    broker_id,
                    d.plan_type
                having
                    sum(check_amount) > 0
            ) loop
                l_record.er_acc_num := x.acc_num;
                l_record.salesrep_id := x.salesrep_id;
                l_record.renewal := x.renewal;
                l_record.entrp_id := x.entrp_id;
                l_record.acc_num := x.acc_num;
                l_record.acc_id := x.acc_id;
                l_record.product_type := x.plan_type;
                l_record.employer_name := pc_entrp.get_entrp_name(x.entrp_id);
                l_record.fee_amount := x.check_amount;
                l_record.renewal_date := x.renewal_date;
                l_record.plan_doc_flag := is_plan_doc_only(x.entrp_id, p_account_type, p_start_date, p_end_date);
                l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
                l_record.broker_id := x.broker_id;
                pipe row ( l_record );
            end loop;

        end if;
    end get_summ_salesrep_report_old;

    function get_salesrep_comm_detail (
        p_account_type in varchar2,
        p_salesrep_id  number,
        p_start_date   in date,
        p_end_date     in date
    ) return salerep_comm_det_t
        pipelined
        deterministic
    is
        l_record salerep_comm_det_row;
    begin
        if p_start_date < p_effective_date then
            for x in (
                select
                    employer,
                    acc_num,
                    account_type,
                    sales_rep,
                    fee_paid,
                    creation_date saved_date
                from
                    sales_commission_history
                where
                        product_type = p_account_type
                    and period_start_date >= p_start_date --TO_DATE(P_START_DATE,'MM/DD/YYYY')
                    and period_end_date <= p_end_date --TO_DATE(P_END_DATE,'MM/DD/YYYY')
                    and salesrep_id = p_salesrep_id
            ) loop
                l_record.employer_name := x.employer;
                l_record.acc_num := x.acc_num;
                l_record.account_type := x.account_type;
                l_record.rep_name := x.sales_rep;
                l_record.fee_paid := x.fee_paid;
                l_record.saved_date := x.saved_date;
                pipe row ( l_record );
            end loop;

        else
            for x in (
                select
                    pc_entrp.get_entrp_name(entrp_id)               employer,
                    acc_num,
                    comm_flag,
                    pc_sales_team.get_sales_rep_name(p_salesrep_id) sales_rep,
                    amount,
                    creation_date                                   saved_date
                from
                    sales_commissions_detail
                where
                        account_type = p_account_type
                    and period_start_date >= p_start_date --TO_DATE(P_START_DATE,'MM/DD/YYYY')
                    and period_end_date <= p_end_date --TO_DATE(P_END_DATE,'MM/DD/YYYY')
                    and salesrep_id = p_salesrep_id
                    and amount > 0
            ) loop
                l_record.employer_name := x.employer;
                l_record.acc_num := x.acc_num;
                l_record.account_type := x.comm_flag;
                l_record.rep_name := x.sales_rep;
                l_record.fee_paid := x.amount;
                l_record.saved_date := x.saved_date;
                pipe row ( l_record );
            end loop;
        end if;
    end get_salesrep_comm_detail;

/* Procedure created by Swamy for Ticket#7766  */
    procedure insert_sales_commission_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
    begin
--pc_log.log_error('Insert_Sales_Commission_Report','In Proc');

        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;

    -- Before inserting the previous months records, delete all the previous months records.
        delete from sales_commission_report
        where
            insert_id = v_insert_id;

-- Query for COBRA/ERISA/FORM_550/CMP
        for i in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                reg_date,
                account_type,
                sum(total_line_amount)                    commissionable_revenue,
                enrolled,
                eligible
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        d.reg_date,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        nvl(
                            pc_entrp.count_person(d.entrp_id),
                            0
                        )                                   as enrolled,
                        nvl(
                            pc_entrp.get_eligible_count(d.entrp_id),
                            0
                        )                                   as eligible
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d,
                        salesrep         s
                    where
                            a.invoice_id = b.invoice_id
		  /*AND(( A.APPROVED_DATE  BETWEEN  TO_CHAR(TRUNC(SYSDATE, 'MM'),'DD-MON-YYYY')  AND to_char(last_day(sysdate),'DD-MON-YYYY')
		       AND A. START_DATE <= to_char(last_day(sysdate),'DD-MON-YYYY'))
		   OR (A.START_DATE BETWEEN  TO_CHAR(TRUNC(SYSDATE, 'MM'),'DD-MON-YYYY') AND to_char(last_day(sysdate),'DD-MON-YYYY')
		       AND A.APPROVED_DATE <  TO_CHAR(TRUNC(SYSDATE, 'MM'),'DD-MON-YYYY')))*/
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code in ( 1, 100, 43, 44, 52 )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
                        and a.salesrep_id = s.salesrep_id  -- IN (522,721,1781,341,921,1741,1721) by Joshi 7922
                        and s.role_type in ( 'SALESREP', 'AM' )
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                enrolled,
                eligible,
                name,
                reg_date
        ) loop
            insert into sales_commission_report (
                salesrep_id,
                salesrep,
                amount,
                eligible,
                enrolled,
                commissionable_revenue,
                annualized_revenue,
                group_name,
                account_type,
                reg_date,
                enrolled_annual,
                eligible_annual,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by
            ) values ( i.salesrep_id,
                       i.salesrep,
                       i.amount,
                       i.eligible,
                       i.enrolled,
                       i.commissionable_revenue,
                       0,
                       i.name,
                       i.account_type,
                       i.reg_date,
                       0,
                       0,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0 );

        end loop;

        pc_log.log_error('Insert_Sales_Commission_Report', 'After Insert');

--QUERY FOR FSA/HRA
        for j in (
            select
                sum(total_line_amount)                                              as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id)                           as salesrep,
                name,
                reg_date,
                enrolled,
                eligible,
                enrolled_annual,
                eligible_annual,
                greatest(enrolled_annual, eligible_annual)                          as annualized,
                account_type,
                sum(total_line_amount) + greatest(enrolled_annual, eligible_annual) as commissionable_revenue
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        d.reg_date,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        nvl((pc_entrp.count_active_person(d.entrp_id)),
                            0)                              as enrolled,
                        nvl((pc_entrp.get_eligible_count(d.entrp_id)),
                            0)                              as eligible,
                        ( nvl(
                            pc_entrp.count_active_person(d.entrp_id),
                            0
                        ) * 5 * 12 )                        as enrolled_annual,
                        ( ( 5 / 100 * nvl(
                            pc_entrp.get_eligible_count(d.entrp_id),
                            0
                        ) ) * 5 * 12 )                      as eligible_annual
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d,
                        salesrep         s
                    where
                            a.invoice_id = b.invoice_id
                 /* AND(( A.APPROVED_DATE  BETWEEN  TO_CHAR(TRUNC(SYSDATE, 'MM'),'DD-MON-YYYY')  AND to_char(last_day(sysdate),'DD-MON-YYYY')
                       AND A. START_DATE <= to_char(last_day(sysdate),'DD-MON-YYYY'))
                   OR (A.START_DATE BETWEEN  TO_CHAR(TRUNC(SYSDATE, 'MM'),'DD-MON-YYYY') AND to_char(last_day(sysdate),'DD-MON-YYYY')
                       AND A.APPROVED_DATE <  TO_CHAR(TRUNC(SYSDATE, 'MM'),'DD-MON-YYYY')))*/
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'FSA', 'HRA' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code in ( 1, 100, 43, 44 )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
                        and a.salesrep_id = s.salesrep_id -- IN (522,721,1781,341,921,1741,1721,741,781,1641,1601)
                        and s.role_type in ( 'SALESREP', 'AM' )
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                enrolled,
                eligible,
                name,
                reg_date,
                enrolled_annual,
                eligible_annual
        ) loop
            insert into sales_commission_report (
                salesrep_id,
                salesrep,
                amount,
                eligible,
                enrolled,
                commissionable_revenue,
                annualized_revenue,
                group_name,
                account_type,
                reg_date,
                enrolled_annual,
                eligible_annual,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by
            ) values ( j.salesrep_id,
                       j.salesrep,
                       j.amount,
                       j.eligible,
                       j.enrolled,
                       j.commissionable_revenue,
                       j.annualized,
                       j.name,
                       j.account_type,
                       j.reg_date,
                       j.enrolled_annual,
                       j.eligible_annual,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0 );

        end loop;

--QUERY FOR HSA
        for k in (
            select
                sum(amount)                                as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id)  as salesrep,
                name,
                reg_date,
                enrolled,
                eligible,
                enrolled_annual,
                eligible_annual,
                greatest(enrolled_annual, eligible_annual) as annualized,
                account_type,
                greatest(enrolled_annual, eligible_annual) as commissionable_revenue
            from
                (
                    select
                        d.fee_maint                         as amount,
                        d.salesrep_id,
                        d.account_type,
                        d.reg_date,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        nvl((pc_entrp.count_active_person(d.entrp_id)),
                            0)                              as enrolled,
                        nvl((pc_entrp.get_eligible_count(d.entrp_id)),
                            0)                              as eligible,
                        ( nvl(
                            pc_entrp.count_active_person(d.entrp_id),
                            0
                        ) * 250 )                           as enrolled_annual,
                        nvl(((5 / 100 * pc_entrp.get_eligible_count(d.entrp_id)) * 250),
                            0)                              as eligible_annual
                    from
                        account  d,
                        salesrep s
                    where
                            d.account_type = 'HSA'
                        and d.account_status = 1
                        and d.entrp_id is not null
                        and pc_entrp.count_active_person(d.entrp_id) > 0
                       -- AND D.PLAN_CODE NOT IN (5,6,7)
                        and d.salesrep_id = s.salesrep_id  -- IN (522,721,1781,341,921,1741,1721,741,781,1641,1601)
                        and s.role_type in ( 'SALESREP', 'AM' )
                        and trunc(d.reg_date) between v_period_start and v_period_end
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                enrolled,
                eligible,
                name,
                reg_date,
                enrolled_annual,
                eligible_annual
   /* UNION ALL
    SELECT  SUM (AMOUNT) AS "AMOUNT" ,
            SALESREP_ID ,
            PC_ACCOUNT.GET_SALESREP_NAME(salesrep_id) AS "SALESREP" ,
            NAME     ,
            REG_DATE ,
            ENROLLED ,
            ELIGIBLE ,
            ENROLLED_ANNUAL ,
            ELIGIBLE_ANNUAL ,
            GREATEST(ENROLLED_ANNUAL,ELIGIBLE_ANNUAL) AS "ANNUALIZED" ,
            ACCOUNT_TYPE ,
            GREATEST(ENROLLED_ANNUAL,ELIGIBLE_ANNUAL) AS "COMMISSIONABLE_REVENUE"
      FROM (SELECT (PC_ENTRP.COUNT_PERSON(D.ENTRP_ID)*D.FEE_MAINT) AS "AMOUNT" ,
                   D.salesrep_id ,
                   D.ACCOUNT_TYPE ,
                   D.REG_DATE,
                   PC_ENTRP.GET_ENTRP_NAME(D.ENTRP_ID) AS "NAME"
                   ,NVL((PC_ENTRP.COUNT_PERSON(D.ENTRP_ID)),0) AS "ENROLLED"
                   ,NVL((PC_ENTRP.GET_ELIGIBLE_COUNT(D.ENTRP_ID)),0)AS "ELIGIBLE"
                  ,(NVL(PC_ENTRP.COUNT_PERSON(D.ENTRP_ID),0)*D.FEE_MAINT) AS "ENROLLED_ANNUAL"
                  ,NVL(((5/100*PC_ENTRP.GET_ELIGIBLE_COUNT(D.ENTRP_ID))*D.FEE_MAINT),0) AS "ELIGIBLE_ANNUAL"
             FROM ACCOUNT d , salesrep s
            WHERE D.ACCOUNT_TYPE = 'HSA'
              AND D.ACCOUNT_status = 1
              AND D.PLAN_CODE  IN (5,6,7)
              AND D.ENTRP_ID IS NOT NULL
              AND D.salesrep_id = s.salesrep_id -- IN (522,721,1781,341,921,1741,1721,741,781,1641,1601)
              AND s.role_type in ('SALESREP','AM')
              AND D.REG_DATE BETWEEN V_period_Start AND V_period_End)
         GROUP BY pc_account.get_salesrep_name(SALESREP_ID),SALESREP_ID,ACCOUNT_TYPE,ENROLLED,ELIGIBLE,NAME,REG_DATE,ENROLLED_ANNUAL,ELIGIBLE_ANNUAL
 */
        ) loop
            insert into sales_commission_report (
                salesrep_id,
                salesrep,
                amount,
                eligible,
                enrolled,
                commissionable_revenue,
                annualized_revenue,
                group_name,
                account_type,
                reg_date,
                enrolled_annual,
                eligible_annual,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by
            ) values ( k.salesrep_id,
                       k.salesrep,
                       k.amount,
                       k.eligible,
                       k.enrolled,
                       k.commissionable_revenue,
                       k.annualized,
                       k.name,
                       k.account_type,
                       k.reg_date,
                       k.enrolled_annual,
                       k.eligible_annual,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0 );

        end loop;

        pc_log.log_error('Insert_Sales_Commission_Report', 'End');
    exception
        when others then
            pc_log.log_error('Insert_Sales_Commission_Report', sqlerrm);
    end insert_sales_commission_report;

/*Procedure Added By Shavee on 05_12_2020*/
    procedure monthly_new_revenue_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
    begin
        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;
    
    -- Delete all the records before insertion.
   -- Delete from MONTHLY_NEW_REVENUE_REPORT where Insert_ID = v_Insert_ID;--Updated by Shavee on 07_28
        delete from monthly_new_rev_report
        where
            insert_id = v_insert_id;--Updated by Shavee on 07_28

-- Query for COBRA/ERISA/FORM_550/CMP/ACA/POP
        for i in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                invoice_id,
                acc_id,
                status,
                line_status,
                reason_code
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        d.acc_id,
                        a.status                            as status,
                        b.status                            as line_status,
                        c.reason_code
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code in ( 1, 100, 43, 44, 184 )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
        ) loop
            insert into monthly_new_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status,
                reason_code
            ) values ( i.salesrep_id,
                       i.salesrep,
                       i.amount,
                       i.name,
                       i.account_type,
                       i.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       i.invoice_id,
                       i.status,
                       i.line_status,
                       i.reason_code );

        end loop;		  

--QUERY FOR FSA/HRA MONTHLY
        for j in (
            select
                sum(total_line_amount)                    as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
            from
                (
                    select
                        (
                            case
                                when d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                         'ACA', 'FSA', 'HRA', 'RB' )
                                     and c.reason_code in ( 2, 35, 31, 33, 67,
                                                            34, 68, 36, 39, 38,
                                                            37, 32, 40 )
                                     and greatest(
                                    trunc(d.reg_date),
                                    trunc(d.start_date)
                                ) >= add_months(
                                    trunc(a.start_date),
                                    -11
                                ) then
                                    b.total_line_amount
                                when d.account_type = 'FMLA'
                                     and c.reason_code = 2
                                     and ( greatest(
                                    trunc(d.reg_date),
                                    trunc(d.start_date)
                                ) >= add_months(
                                    trunc(a.start_date),
                                    -11
                                ) ) then
                                    b.total_line_amount
                                else
                                    0
                            end
                        )                                   total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        d.acc_id,
                        a.status                            as status,
                        b.status                            as line_status,
                        c.reason_code
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                --  AND D.ACCOUNT_TYPE IN ('COBRA','ERISA_WRAP','CMP','FORM_5500','POP','ACA','FSA','HRA','FMLA','RB')
                        and a.invoice_reason = 'FEE'
                --  AND C.REASON_CODE IN  (2,35,31,33,67,34,68,36,39,38,37,32,40,54,55,86)
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
                        and greatest(
                            trunc(d.reg_date),
                            trunc(d.start_date)
                        ) >= add_months(
                            trunc(a.start_date),
                            -11
                        )
              --    AND a.salesrep_id IN (522,721,1781,341,921,1741,1721,741,781,1641,1601)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
        ) loop
            insert into monthly_new_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status,
                reason_code
            ) values ( j.salesrep_id,
                       j.salesrep,
                       j.amount,
                       j.name,
                       j.account_type,
                       j.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       j.invoice_id,
                       j.status,
                       j.line_status,
                       j.reason_code );

        end loop;		  
		   
--QUERY FOR HSA
        for k in (
            select
                sum(amount)                               as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                acc_id,
                status,
                null,
                reason_code
            from
                (
                    select
                        p.amount                            as amount,
                        d.salesrep_id,
                        d.account_type,
                        d.acc_id,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        d.account_status                    as status,
                        null,
                        p.reason_code
                    from
                        person  a,
                        account d,
                        payment p,
                        account er
                    where
                        d.account_type in ( 'HSA', 'LSA' )
                        and d.pers_id = a.pers_id
                        and p.acc_id = d.acc_id
                        and a.entrp_id = er.entrp_id
                        and a.entrp_id is not null
                        and trunc(p.pay_date) between v_period_start and v_period_end
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                        and p.reason_code in ( 2, 100 )
                        and months_between(pay_date, er.start_date) <= 12
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                status,
                reason_code
        ) loop
            insert into monthly_new_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status,
                reason_code
            ) values ( k.salesrep_id,
                       k.salesrep,
                       k.amount,
                       k.name,
                       k.account_type,
                       k.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       k.acc_id,
                       k.status,
                       null,
                       k.reason_code );

        end loop; 
  
  --SK Added on 05/06/2021 to capture discounts
        for p in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        d.acc_id,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status,
                        c.reason_code
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and ( b.rate_code = 264
                              or ( b.rate_code in ( 89, 266 )
                                   and exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = b.invoice_id
                                and rate_code in ( 1, 100, 43, 44, 184 )
                        ) ) )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                acc_id,
                status,
                line_status,
                reason_code
        ) loop
            insert into monthly_new_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status,
                reason_code
            ) values ( p.salesrep_id,
                       p.salesrep,
                       p.amount,
                       p.name,
                       p.account_type,
                       p.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       p.invoice_id,
                       p.status,
                       p.line_status,
                       p.reason_code );

        end loop;		  
 /* Sk added to capture Optional services*/
        for z in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        d.acc_id,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status,
                        c.reason_code
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type = 'COBRA'
                        and a.invoice_reason = 'FEE'
                        and b.rate_code in ( 54, 55, 86 )
                        and exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = b.invoice_id
                                and rate_code in ( 1, 100, 43, 44, 184 )
                        )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
        ) loop
            insert into monthly_new_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status,
                reason_code
            ) values ( z.salesrep_id,
                       z.salesrep,
                       z.amount,
                       z.name,
                       z.account_type,
                       z.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       z.invoice_id,
                       z.status,
                       z.line_status,
                       z.reason_code );

        end loop;	

 /* Sk added to capture Optional stanadlone services 12-04-2024*/
        for s in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        d.acc_id,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status,
                        c.reason_code
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type = 'COBRA'
                        and a.invoice_reason = 'FEE'
		  /*AND b.Rate_code IN (54,55,86) and exists (select * from ar_invoice_lines where invoice_id=
          b.invoice_id and rate_code IN (1,100,43,44,184))*/
                        and b.rate_code in ( 54, 55, 86 )
                        and not exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = b.invoice_id
                                and rate_code in ( 1, 100, 43, 44, 184 )
                        )
                        and ( greatest(
                            trunc(d.reg_date),
                            trunc(d.start_date)
                        ) >= add_months(
                            trunc(a.start_date),
                            -11
                        ) )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
        ) loop
            insert into monthly_new_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status,
                reason_code
            ) values ( s.salesrep_id,
                       s.salesrep,
                       s.amount,
                       s.name,
                       s.account_type,
                       s.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       s.invoice_id,
                       s.status,
                       s.line_status,
                       s.reason_code );

        end loop;		
    --QUERY FOR VOID
        for l in (
            select
                sum(total_line_amount)                    as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                acc_id,
                invoice_id,
                status,
                line_status,
                reason_code
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        d.acc_id,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status,
                        c.reason_code
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( trunc(a.void_date) between v_period_start and v_period_end
                              and trunc(a.start_date) < v_period_end
                              and trunc(a.approved_date) < v_period_start )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code in ( 2, 35, 31, 33, 67,
                                               34, 68, 36, 39, 38,
                                               37, 32, 40, 54, 55,
                                               86, 1, 100, 43, 44,
                                               184 )
                        and ( a.status = 'VOID'
                              or b.status = 'VOID' )
                        and b.rate_code = to_char(c.reason_code)
                        and greatest(
                            trunc(d.reg_date),
                            trunc(d.start_date)
                        ) >= add_months(
                            trunc(a.start_date),
                            -11
                        )
              --    AND a.salesrep_id IN (522,721,1781,341,921,1741,1721,741,781,1641,1601)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                acc_id,
                name,
                invoice_id,
                status,
                line_status,
                reason_code
        ) loop
            insert into monthly_new_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status,
                reason_code
            ) values ( l.salesrep_id,
                       l.salesrep,
                       l.amount,
                       l.name,
                       l.account_type,
                       l.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       l.invoice_id,
                       l.status,
                       l.line_status,
                       l.reason_code );

        end loop;

        pc_log.log_error('MONTHLY_NEW_REVENUE_REPORT', 'End');
    exception
        when others then
            pc_log.log_error('MONTHLY_NEW_REVENUE_REPORT', sqlerrm);
    end monthly_new_revenue_report;
--SK Added on 05_12
    procedure monthly_renewal_revenue_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
    begin
        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;
    
    -- Delete all the records before insertion.
        delete from monthly_renewal_rev_report
        where
            insert_id = v_insert_id;

-- Query for COBRA/ERISA/FORM_550/CMP/ACA/POP
        for i in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code in ( 30, 45, 46, 182 )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                invoice_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_status,
                invoice_line_status
            ) values ( i.salesrep_id,
                       i.salesrep,
                       i.amount,
                       i.name,
                       i.account_type,
                       i.invoice_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       i.status,
                       i.line_status );

        end loop;		  

--QUERY FOR FSA/HRA/COBRA MONTHLY
        for j in (
            select
                sum(total_line_amount)                    as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code in ( 2, 35, 31, 33, 67,
                                               34, 68, 36, 39, 38,
                                               37, 32, 40 )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
                        and greatest(
                            trunc(d.reg_date),
                            trunc(d.start_date)
                        ) < add_months(
                            trunc(a.start_date),
                            -11
                        )
              --    AND a.salesrep_id IN (522,721,1781,341,921,1741,1721,741,781,1641,1601)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                invoice_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_status,
                invoice_line_status
            ) values ( j.salesrep_id,
                       j.salesrep,
                       j.amount,
                       j.name,
                       j.account_type,
                       j.invoice_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       j.status,
                       j.line_status );

        end loop;

--SK Added on 05/06/2021 to capture discounts
        for s in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB',
                                                'LSA' )
                        and a.invoice_reason = 'FEE'
                        and ( b.rate_code = 265
                              or ( b.rate_code in ( 89, 266 )
                                   and exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = b.invoice_id
                                and rate_code in ( 30, 45, 46, 182 )
                        ) ) )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status
            ) values ( s.salesrep_id,
                       s.salesrep,
                       s.amount,
                       s.name,
                       s.account_type,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       s.invoice_id,
                       s.status,
                       s.line_status );

        end loop;		  
/* Sk Added to capture optional services separately 02-29-2023*/
        for z in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type = 'COBRA'
                        and a.invoice_reason = 'FEE'
                        and b.rate_code in ( 54, 55, 86 )
                        and exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = b.invoice_id
                                and rate_code in ( 30, 45, 46, 182 )
                        )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status
            ) values ( z.salesrep_id,
                       z.salesrep,
                       z.amount,
                       z.name,
                       z.account_type,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       z.invoice_id,
                       z.status,
                       z.line_status );

        end loop;	

/* Sk Added to capture optional Standalone services separately 12-24-2024*/
        for m in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type = 'COBRA'
                        and a.invoice_reason = 'FEE'
                        and b.rate_code in ( 54, 55, 86 )
                        and not exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = b.invoice_id
                                and rate_code in ( 30, 45, 46, 182 )
                        )
                        and ( greatest(
                            trunc(d.reg_date),
                            trunc(d.start_date)
                        ) < add_months(a.start_date, -11) )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status
            ) values ( m.salesrep_id,
                       m.salesrep,
                       m.amount,
                       m.name,
                       m.account_type,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       m.invoice_id,
                       m.status,
                       m.line_status );

        end loop;		  
           
--QUERY FOR HSA
        for k in (
            select
                sum(amount)                               as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                acc_id,
                status,
                null
            from
                (
                    select
                        p.amount                             as amount,
                        d.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(er.entrp_id) as name,
                        d.acc_id,
                        d.account_status                     as status,
                        null
                    from
                        person  a,
                        account d,
                        payment p,
                        account er
                    where
                        d.account_type in ( 'HSA', 'LSA' )
                        and d.pers_id = a.pers_id
                        and p.acc_id = d.acc_id
                        and a.entrp_id = er.entrp_id
                        and a.entrp_id is not null
                        and trunc(p.pay_date) between v_period_start and v_period_end
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                        and p.reason_code in ( 2, 100 )
                        and months_between(pay_date, er.start_date) > 12
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                invoice_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_status,
                invoice_line_status
            ) values ( k.salesrep_id,
                       k.salesrep,
                       k.amount,
                       k.name,
                       k.account_type,
                       k.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       k.status,
                       null );

        end loop; 
  
  
--QUERY FOR HSA NO EMPLOYER 
        for l in (
            select
                sum(amount)                               as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                acc_id,
                status,
                null
            from
                (
                    select
                        p.amount                             as amount,
                        d.salesrep_id,
                        d.account_type,
                        pc_person.get_person_name(a.pers_id) as name,
                        d.acc_id,
                        d.account_status                     as status,
                        null
                    from
                        person  a,
                        account d,
                        payment p
                    where
                            d.account_type = 'HSA'
                        and d.pers_id = a.pers_id
                        and p.acc_id = d.acc_id
                --  AND A.ENTRP_ID=ER.ENTRP_ID
                        and a.entrp_id is null
                        and trunc(p.pay_date) between v_period_start and v_period_end
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                        and p.reason_code in ( 2, 100 )
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                invoice_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_status,
                invoice_line_status
            ) values ( l.salesrep_id,
                       l.salesrep,
                       l.amount,
                       l.name,
                       l.account_type,
                       l.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       l.status,
                       null );

        end loop;

        for p in (
            select
                sum(total_line_amount)                    as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( trunc(a.void_date) between v_period_start and v_period_end
                              and trunc(a.start_date) < v_period_end
                              and trunc(a.approved_date) < v_period_start )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code in ( 2, 35, 31, 33, 67,
                                               34, 68, 36, 39, 38,
                                               37, 32, 40, 54, 55,
                                               86, 30, 45, 46, 182 )
                        and ( a.status = 'VOID'
                              or b.status = 'VOID' )
                        and b.rate_code = to_char(c.reason_code)
                        and greatest(
                            trunc(d.reg_date),
                            trunc(d.start_date)
                        ) < add_months(
                            trunc(a.start_date),
                            -11
                        )
              --    AND a.salesrep_id IN (522,721,1781,341,921,1741,1721,741,781,1641,1601)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_renewal_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status
            ) values ( p.salesrep_id,
                       p.salesrep,
                       p.amount,
                       p.name,
                       p.account_type,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       p.invoice_id,
                       p.status,
                       p.line_status );

        end loop;

        pc_log.log_error('MONTHLY_RENEWAL_REVENUE_REPORT', 'End');
    exception
        when others then
            pc_log.log_error('MONTHLY_RENEWAL_REVENUE_REPORT', sqlerrm);
    end monthly_renewal_revenue_report;

    procedure new_hsa_commission_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
    begin
        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;

        delete from new_hsa_commission_report
        where
            insert_id = v_insert_id;--Updated by Shavee on 07_28

        for k in (
            select
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                acc_id,
                acc_num,
                reg_date,
                first_activity_date,
                start_date
            from
                (
                    select
                        d.salesrep_id,
                        pc_entrp.get_entrp_name(er.entrp_id) as name,
                        d.account_type,
                        d.acc_id,
                        d.acc_num,
                        d.reg_date,
                        d.first_activity_date,
                        er.start_date
                    from
                        person  a,
                        account d
                     -- ,PAYMENT P
                        ,
                        account er
                    where
                            d.account_type = 'HSA'
                        and d.pers_id = a.pers_id
               --   AND   P.ACC_ID = d.ACC_ID
                        and a.entrp_id = er.entrp_id
                        and a.entrp_id is not null
                        and trunc(d.reg_date) between '01-JUN-2021' and '30-SEP-2021'
                        and trunc(d.first_activity_date) between v_period_start and v_period_end
                        and months_between(d.first_activity_date, er.start_date) <= 12
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                acc_num,
                reg_date,
                first_activity_date,
                start_date
        ) loop
            insert into new_hsa_commission_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                acc_id,
                account_number,
                enrollment_date,
                funded_date,
                employer_start_date,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by
            ) values ( k.salesrep_id,
                       k.salesrep,
                       30,
                       k.name,
                       k.account_type,
                       k.acc_id,
                       k.acc_num,
                       k.reg_date,
                       k.first_activity_date,
                       k.start_date,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0 );

        end loop;

        pc_log.log_error('NEW_HSA_COMMISSION_REPORT ', 'End');
    exception
        when others then
            pc_log.log_error('NEW_HSA_COMMISSION_REPORT ', sqlerrm);
    end new_hsa_commission_report;

    procedure monthly_company_rev_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
    begin
        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;
    
    -- Delete all the records before insertion.
        delete from monthly_company_rev_report
        where
            insert_id = v_insert_id;

-- Query for COBRA/ERISA/FORM_550/CMP/ACA/POP
        for i in (
            select
                sum(total_line_amount)                    amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            status,
                        b.status                            line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( ( trunc(a.approved_date) between v_period_start and v_period_end
                                and trunc(a.start_date) <= v_period_end )
                              or ( trunc(a.start_date) between v_period_start and v_period_end
                                   and trunc(a.approved_date) < v_period_start ) )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code not in ( 1, 100, 43, 44, 184,
                                                   30, 45, 46, 182, 2,
                                                   35, 31, 33, 67, 34,
                                                   68, 36, 39, 38, 37,
                                                   32, 40, 54, 55, 86,
                                                   85, 89, 264, 265, 266,
                                                   267, 268 )
                        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                        and b.rate_code = to_char(c.reason_code)
		--  AND A.salesrep_id IN (522,721,1781,341,921,1741,1721)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_company_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                invoice_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_status,
                invoice_line_status
            ) values ( i.salesrep_id,
                       i.salesrep,
                       i.amount,
                       i.name,
                       i.account_type,
                       i.invoice_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       i.status,
                       i.line_status );

        end loop;		  
 
--QUERY FOR HSA NO EMPLOYER 
        for l in (
            select
                sum(amount)                               as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                acc_id,
                status,
                null
            from
                (
                    select
                        p.amount                             as amount,
                        d.salesrep_id,
                        d.account_type,
                        pc_person.get_person_name(a.pers_id) as name,
                        d.acc_id,
                        d.account_status                     status,
                        null
                    from
                        person     a,
                        account    d,
                        payment    p,
                        pay_reason l
                    where
                            d.account_type = 'HSA'
                        and d.pers_id = a.pers_id
                        and p.acc_id = d.acc_id
                        and p.reason_code = l.reason_code
                        and l.reason_type = 'FEE'
                --  AND A.ENTRP_ID=ER.ENTRP_ID
                        and trunc(p.pay_date) between v_period_start and v_period_end
                 -- AND   ACCOUNT.SALESREP_ID IS NOT NULL
                 -- AND  A.PERSON_TYPE <> 'BROKER'
                        and p.reason_code not in ( 2, 100 )
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                acc_id,
                status,
                null
        ) loop
            insert into monthly_company_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                invoice_id,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_status,
                invoice_line_status
            ) values ( l.salesrep_id,
                       l.salesrep,
                       l.amount,
                       l.name,
                       l.account_type,
                       l.acc_id,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       l.status,
                       null );

        end loop;

        for k in (
            select
                sum(total_line_amount)                    as amount,
                salesrep_id,
                pc_account.get_salesrep_name(salesrep_id) as salesrep,
                name,
                account_type,
                invoice_id,
                status,
                line_status
            from
                (
                    select
                        b.total_line_amount,
                        a.salesrep_id,
                        d.account_type,
                        pc_entrp.get_entrp_name(d.entrp_id) as name,
                        a.invoice_id,
                        a.status                            as status,
                        b.status                            as line_status
                    from
                        ar_invoice       a,
                        ar_invoice_lines b,
                        pay_reason       c,
                        account          d
                    where
                            a.invoice_id = b.invoice_id
                        and ( trunc(a.void_date) between v_period_start and v_period_end
                              and trunc(a.start_date) < v_period_end
                              and trunc(a.approved_date) < v_period_start )
                        and a.acc_id = d.acc_id
                        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'CMP', 'FORM_5500', 'POP',
                                                'ACA', 'FSA', 'HRA', 'FMLA', 'RB' )
                        and a.invoice_reason = 'FEE'
                        and c.reason_code not in ( 1, 100, 43, 44, 184,
                                                   30, 45, 46, 182, 2,
                                                   35, 31, 33, 67, 34,
                                                   68, 36, 39, 38, 37,
                                                   32, 40, 54, 55, 86 )
                        and ( a.status = 'VOID'
                              or b.status = 'VOID' )
                        and b.rate_code = to_char(c.reason_code)
                        and a.status <> 'CANCELLED'
                )
            group by
                pc_account.get_salesrep_name(salesrep_id),
                salesrep_id,
                account_type,
                name,
                invoice_id,
                status,
                line_status
        ) loop
            insert into monthly_company_rev_report (
                salesrep_id,
                salesrep,
                amount,
                group_name,
                account_type,
                period_start_date,
                period_end_date,
                insert_id,
                creation_date,
                created_by,
                invoice_id,
                invoice_status,
                invoice_line_status
            ) values ( k.salesrep_id,
                       k.salesrep,
                       k.amount,
                       k.name,
                       k.account_type,
                       v_period_start,
                       v_period_end,
                       v_insert_id,
                       sysdate,
                       0,
                       k.invoice_id,
                       k.status,
                       k.line_status );

        end loop;

        pc_log.log_error('MONTHLY_COMPANY_REV_REPORT', 'End');
    exception
        when others then
            pc_log.log_error('MONTHLY_COMPANY_REV_REPORT', sqlerrm);
    end monthly_company_rev_report;

    procedure generate_sales_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
        ll_count       number;
    begin
--pc_log.log_error('Insert_Sales_Commission_Report','In Proc');

        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;

        select
            count(*)
        into ll_count
        from
            sales_summary_report
        where
            insert_id = v_insert_id;

        if ll_count = 0 then
            for x in (
                select
                    a.salesrep_id,
                    a.salesrep,
                    sum(a.commissionable_revenue) commissionable_revenue -- total_amount --, sum(amount) + greatest(ENROLLED_ANNUAL,ELIGIBLE_ANNUAL)  "COMMISSIONABLE_REVENUE"
                from
                    sales_commission_report a
                where
                    a.insert_id = v_insert_id
                group by
                    a.salesrep_id,
                    a.salesrep
            ) loop
                insert into sales_summary_report (
                    salesrep_id,
                    salesrep,
                    commissionable_revenue,
                    start_date,
                    end_date,
                    insert_id
                ) values ( x.salesrep_id,
                           x.salesrep,
                           x.commissionable_revenue,
                           v_period_start,
                           v_period_end,
                           v_insert_id );

            end loop;

         -- calculate YTD Revenue.
            update sales_summary_report s
            set
                s.ytd_revenue = (
                    select
                        sum(a.commissionable_revenue)
                    from
                        sales_commission_report a
                    where
                            a.salesrep_id = s.salesrep_id
                        and substr(a.insert_id, 3, 4) = substr(v_insert_id, 3, 4)
                )
            where
                s.insert_id = v_insert_id;

         -- Calculate monthly commission.
            update sales_summary_report s
            set
                s.comm_percentage = (
                    select
                        a.comm_percentage
                    from
                        sales_commission_range a
                    where
                        ( ( s.ytd_revenue between a.from_range and a.to_range )
                          or ( s.ytd_revenue >= a.from_range
                               and a.to_range is null ) )
                        and a.salesrep_role = (
                            select
                                sr.role_type
                            from
                                salesrep sr
                            where
                                sr.salesrep_id = s.salesrep_id
                        )
                )
            where
                s.insert_id = v_insert_id;

         -- update commission amount.
            update sales_summary_report
            set
                commission_amount = commissionable_revenue * nvl(comm_percentage, 1) / 100
            where
                insert_id = v_insert_id;

        end if;

    end generate_sales_summary_report;

    procedure monthly_new_rev_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
        ll_count       number;
    begin
--pc_log.log_error('Insert_Sales_Commission_Report','In Proc');

        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;

        select
            count(*)
        into ll_count
        from
            monthly_new_rev_summary_report
        where
            insert_id = v_insert_id;

        if ll_count = 0 then
            for x in (
                select
                    sum(approved)                 approved,
                    sum(void)                     void,
                    ( sum(approved) - sum(void) ) total_revenue,
                    period_start_date,
                    period_end_date,
                    insert_id
                from
                    (
                        select
                            sum(
                                case
                                    when(a.invoice_status != 'VOID'
                                         or a.invoice_line_status != 'VOID') then
                                        amount
                                    else
                                        0
                                end
                            ) approved,
                            sum(
                                case
                                    when(a.invoice_status = 'VOID'
                                         or a.invoice_line_status = 'VOID') then
                                        amount
                                    else
                                        0
                                end
                            ) void,
                            a.period_start_date,
                            a.period_end_date,
                            a.insert_id
                        from
                            monthly_new_rev_report a
                        where
                            a.insert_id = v_insert_id
                        group by
                            a.period_start_date,
                            a.period_end_date,
                            a.insert_id
                    )
                group by
                    approved,
                    void,
                    period_start_date,
                    period_end_date,
                    insert_id
            ) loop
                insert into monthly_new_rev_summary_report (
                    approved,
                    void,
                    total_revenue,
                    period_start_date,
                    period_end_date,
                    insert_id
                ) values ( x.approved,
                           x.void,
                           x.total_revenue,
                           v_period_start,
                           v_period_end,
                           v_insert_id );

            end loop;
        end if;

    end monthly_new_rev_summary_report;

    procedure monthly_rwl_rev_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
        ll_count       number;
    begin
--pc_log.log_error('Insert_Sales_Commission_Report','In Proc');

        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;

        select
            count(*)
        into ll_count
        from
            monthly_rwl_rev_summary_report
        where
            insert_id = v_insert_id;

        if ll_count = 0 then
            for x in (
                select
                    sum(approved)                 approved,
                    sum(void)                     void,
                    ( sum(approved) - sum(void) ) total_revenue,
                    period_start_date,
                    period_end_date,
                    insert_id
                from
                    (
                        select
                            sum(
                                case
                                    when(a.invoice_status != 'VOID'
                                         or a.invoice_line_status != 'VOID') then
                                        amount
                                    else
                                        0
                                end
                            ) approved,
                            sum(
                                case
                                    when(a.invoice_status = 'VOID'
                                         or a.invoice_line_status = 'VOID') then
                                        amount
                                    else
                                        0
                                end
                            ) void,
                            a.period_start_date,
                            a.period_end_date,
                            a.insert_id
                        from
                            monthly_renewal_rev_report a
                        where
                            a.insert_id = v_insert_id
                        group by
                            a.period_start_date,
                            a.period_end_date,
                            a.insert_id
                    )
                group by
                    approved,
                    void,
                    period_start_date,
                    period_end_date,
                    insert_id
            ) loop
                insert into monthly_rwl_rev_summary_report (
                    approved,
                    void,
                    total_revenue,
                    period_start_date,
                    period_end_date,
                    insert_id
                ) values ( x.approved,
                           x.void,
                           x.total_revenue,
                           v_period_start,
                           v_period_end,
                           v_insert_id );

            end loop;
        end if;

    end monthly_rwl_rev_summary_report;

    procedure monthly_cpy_rev_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    ) is
   -- Variable Declaration
        v_insert_id    varchar2(10);
        v_period_start date;
        v_period_end   date;
        ll_count       number;
    begin
--pc_log.log_error('Insert_Sales_Commission_Report','In Proc');

        if p_start_date is null then
         -- Start date of the Previous month
            v_period_start := trunc(last_day(add_months(sysdate, -2)) + 1);
        -- End Date of the Previous month
            v_period_end := trunc(last_day(add_months(sysdate, -1)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        else
        -- Start date of the Previous month
            v_period_start := trunc(p_start_date);
        -- End Date of the Previous month
            v_period_end := trunc(nvl(p_end_date,
                                      last_day(p_start_date)));
        -- ID to indentify the previous month and previous year
            v_insert_id := to_char(v_period_start, 'MMYYYY');
        end if;

        select
            count(*)
        into ll_count
        from
            monthly_cpy_rev_summary_report
        where
            insert_id = v_insert_id;

        if ll_count = 0 then
            for x in (
                select
                    sum(approved)                 approved,
                    sum(void)                     void,
                    ( sum(approved) - sum(void) ) total_revenue,
                    period_start_date,
                    period_end_date,
                    insert_id
                from
                    (
                        select
                            sum(
                                case
                                    when(a.invoice_status != 'VOID'
                                         or a.invoice_line_status != 'VOID') then
                                        amount
                                    else
                                        0
                                end
                            ) approved,
                            sum(
                                case
                                    when(a.invoice_status = 'VOID'
                                         or a.invoice_line_status = 'VOID') then
                                        amount
                                    else
                                        0
                                end
                            ) void,
                            a.period_start_date,
                            a.period_end_date,
                            a.insert_id
                        from
                            monthly_company_rev_report a
                        where
                            a.insert_id = v_insert_id
                        group by
                            a.period_start_date,
                            a.period_end_date,
                            a.insert_id
                    )
                group by
                    approved,
                    void,
                    period_start_date,
                    period_end_date,
                    insert_id
            ) loop
                insert into monthly_cpy_rev_summary_report (
                    approved,
                    void,
                    total_revenue,
                    period_start_date,
                    period_end_date,
                    insert_id
                ) values ( x.approved,
                           x.void,
                           x.total_revenue,
                           v_period_start,
                           v_period_end,
                           v_insert_id );

            end loop;
        end if;

    end monthly_cpy_rev_summary_report;

end pc_commission;
/

