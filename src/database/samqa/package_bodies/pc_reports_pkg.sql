create or replace package body samqa.pc_reports_pkg as

    function get_dvsn_cd (
        p_division_code varchar2
    ) return varchar2 is
    begin
        return replace(
            replace(p_division_code, 'NO_DIVISION', null),
            'ALL_DIVISION',
            null
        );
    end;

    function get_acc_count (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number,
        p_status        in varchar2
    ) return number is
        l_count number := 0;
    begin
        if nvl(p_status, 'OPEN') <> 'INV' then
            select
                count(*)
            into l_count
            from
                account acc,
                person  p
            where
                    acc.pers_id = p.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )--and sys_op_map_nonnull(division_code)=nvl(get_dvsn_cd(p_division_code),sys_op_map_nonnull(division_code))
                and p.entrp_id = p_entrp_id
                and trunc(acc.start_date, 'MM') = to_date('01-'
                                                          || p_month
                                                          || '-'
                                                          || p_year, 'DD-MM-YYYY')
                and ( ( p_status is not null
                        and acc.account_status = decode(p_status, 'PENDING', 3, 'ACTIVE', 1,
                                                        'CLOSED', 4) )
                      or ( p_status is null
                           and acc.account_status in ( 1, 2, 3 ) ) );

        else
            select
                count(*)
            into l_count
            from
                account    acc,
                person     p,
                investment i
            where
                    acc.pers_id = p.pers_id
                and acc.acc_id = i.acc_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and p.entrp_id = p_entrp_id
                and trunc(i.start_date, 'MM') = to_date('01-'
                                                        || p_month
                                                        || '-'
                                                        || p_year, 'DD-MM-YYYY')
                and i.end_date is null;

        end if;

        return l_count;
    end get_acc_count;

    function get_all_acc_count (
        p_entrp_id      number,
        p_division_code varchar2,
        p_status        varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_count number := 0;
        l_date  date;
    begin
        if
            p_month is not null
            and p_year is not null
        then
            l_date := to_date ( '01-'
                                || p_month
                                || '-'
                                || p_year, 'DD-MM-YYYY' );
        else
            l_date := sysdate;
        end if;

        if nvl(p_status, 'X') <> 'INV' then
            select
                count(*)
            into l_count
            from
                account acc,
                person  p
            where
                    acc.pers_id = p.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and p.entrp_id = p_entrp_id
                and trunc(acc.start_date, 'MM') <= l_date
                and ( ( p_status is not null
                        and acc.account_status = decode(p_status, 'PENDING', 3, 'ACTIVE', 1,
                                                        'CLOSED', 4) )
                      or ( p_status is null
                           and acc.account_status in ( 1, 2, 3 ) ) );

        else
            select
                count(*)
            into l_count
            from
                account    acc,
                person     p,
                investment i
            where
                    acc.acc_id = i.acc_id
                and acc.pers_id = p.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and p.entrp_id = p_entrp_id
                and ( ( p_status is not null
                        and acc.account_status = decode(p_status, 'PENDING', 3, 'ACTIVE', 1,
                                                        'CLOSED', 4) )
                      or ( p_status is null
                           and acc.account_status in ( 1, 2, 3 ) ) )
                and trunc(i.start_date, 'MM') <= l_date
                and i.end_date is null;

        end if;

        return l_count;
    end get_all_acc_count;

    function get_card_count (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_count number := 0;
    begin
        pc_log.log_error('get_card_count', 'entrp_id '
                                           || p_entrp_id
                                           || ' month '
                                           || p_month
                                           || ' year '
                                           || p_year);

        select
            count(acc_num)
        into l_count
        from
            (
                select
                    acc.acc_num,
                    p.entrp_id,
                    count(mc.card_number)
                from
                    account         acc,
                    person          p,
                    metavante_cards mc
                where
                        acc.acc_num = mc.acc_num
                    and p.pers_id = acc.pers_id
                    and ( p_division_code is null
                          or division_code = nvl(
                        get_dvsn_cd(p_division_code),
                        division_code
                    ) )
                    and p.entrp_id = p_entrp_id
     /*   AND   TO_DATE(MC.issue_date,'YYYYMMDD') = CASE WHEN p_month IS NOT NULL AND p_year IS NOT NULL THEN
                                                     TO_DATE('01-'||p_month||'-'||p_year, 'DD-MM-YYYY')
                                                  ELSE TO_DATE(MC.issue_date,'YYYYMMDD') END*/
                    and mc.status_code not in ( 4, 5 )
                    and acc.account_status in ( 1, 2, 3 )
                group by
                    p.entrp_id,
                    acc.acc_num
                having
                    count(mc.card_number) >= 2
            );

        pc_log.log_error('get_card_count', 'l_count ' || l_count);
        return l_count;
    end get_card_count;

    function get_card_not_active_count (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_count number := 0;
    begin
        select
            count(acc_num)
        into l_count
        from
            (
                select
                    acc.acc_num,
                    p.entrp_id,
                    count(mc.card_number)
                from
                    account         acc,
                    person          p,
                    metavante_cards mc
                where
                        acc.acc_num = mc.acc_num
                    and p.pers_id = acc.pers_id
                    and ( p_division_code is null
                          or division_code = nvl(
                        get_dvsn_cd(p_division_code),
                        division_code
                    ) )
                    and p.entrp_id = p_entrp_id
     /*   AND   TO_DATE(MC.issue_date,'YYYYMMDD') = CASE WHEN p_month IS NOT NULL AND p_year IS NOT NULL THEN
                                                     TO_DATE('01-'||p_month||'-'||p_year, 'DD-MM-YYYY')
                                                  ELSE TO_DATE(MC.issue_date,'YYYYMMDD') END*/
                    and mc.status_code = 1
                    and acc.account_status in ( 1, 2, 3 )
                group by
                    p.entrp_id,
                    acc.acc_num
            );

        return l_count;
    end get_card_not_active_count;

    function get_ben_count (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_count number := 0;
    begin
        pc_log.log_error('get_ben_count', 'entrp_id '
                                          || p_entrp_id
                                          || ' month '
                                          || p_month
                                          || ' year '
                                          || p_year);

        select
            count(distinct c.acc_id)
        into l_count
        from
            beneficiary acc,
            person      p,
            account     c
        where
                acc.pers_id = p.pers_id
            and c.pers_id = p.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
   /*    AND    TRUNC(acc.effective_date) = CASE WHEN p_month IS NOT NULL AND p_year IS NOT NULL THEN
                                             TO_DATE('01-'||p_month||'-'||p_year, 'DD-MM-YYYY')
                                          ELSE TRUNC(acc.effective_date) END*/
            and c.account_status in ( 1, 2, 3 )
            and p.entrp_id = p_entrp_id;

        pc_log.log_error('get_card_count', 'l_count ' || l_count);
        return l_count;
    end get_ben_count;

    function get_active_user_count (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            online_users acc,
            person       p,
            account      c
        where
                c.pers_id = p.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and replace(p.ssn, '-') = acc.tax_id
            and c.account_status in ( 1, 2, 3 )
            and p.entrp_id = p_entrp_id
            and sysdate - format_to_date(substr(last_login, 1, 10)) < 90;

        return l_count;
    end get_active_user_count;

    function get_acc_email_count (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            person  p,
            account c
        where
                c.pers_id = p.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and p.entrp_id = p_entrp_id
    /*   AND    TRUNC(c.start_date) = CASE WHEN p_month IS NOT NULL AND p_year IS NOT NULL THEN
                                             TO_DATE('01-'||p_month||'-'||p_year, 'DD-MM-YYYY')
                                          ELSE TRUNC(c.start_date) END*/
            and c.account_status in ( 1, 2, 3 )
            and p.email is not null;

        return l_count;
    end get_acc_email_count;

    function get_acc_balance (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_balance number := 0;
    begin
        select
            sum(nvl(
                pc_account.new_acc_balance(acc.acc_id,
                                           '01-JAN-2004',
                                           last_day(to_date('01-'
                                                            || p_month
                                                            || '-'
                                                            || p_year, 'DD-MM-YYYY'))),
                0
            ))
        into l_balance
        from
            person  p,
            account acc
        where
                p.pers_id = acc.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and p.entrp_id = p_entrp_id;

        return l_balance;
    end get_acc_balance;

    function get_acc_inv_bal (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return number is
        l_balance number := 0;
    begin
        select
            sum(nvl(
                pc_account.outside_inv_balance(acc.acc_id,
                                               last_day(to_date('01-'
                                                                || p_month
                                                                || '-'
                                                                || p_year, 'DD-MM-YYYY'))),
                0
            ))
        into l_balance
        from
            person  p,
            account acc
        where
                p.pers_id = acc.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and p.entrp_id = p_entrp_id;

        return l_balance;
    end get_acc_inv_bal;

    function get_overview_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return overview_t
        pipelined
        deterministic
    is

        l_record_t overview_row_t;
        cursor cur_overview is
        select
            get_acc_count(p_entrp_id, p_division_code, p_month, p_year, null)      open_acc,
            get_acc_count(p_entrp_id, p_division_code, p_month, p_year, 'PENDING') pending_acc,
            get_acc_count(p_entrp_id, p_division_code, p_month, p_year, 'CLOSED')  closed_acc,
            get_acc_count(p_entrp_id, p_division_code, p_month, p_year, 'INV')     inv_acc,
            get_all_acc_count(p_entrp_id, p_division_code, null)                   all_open_acc,
            get_all_acc_count(p_entrp_id, p_division_code, 'PENDING')              all_pending_acc,
            get_all_acc_count(p_entrp_id, p_division_code, 'CLOSED')               all_closed_acc,
            get_all_acc_count(p_entrp_id, p_division_code, 'INV')                  all_inv_acc
        from
            dual;

    begin
        for c1 in cur_overview loop
            l_record_t.open_mm := c1.open_acc;
            l_record_t.pending_mm := c1.pending_acc;
            l_record_t.close_mm := c1.closed_acc;
            l_record_t.inv_mm := c1.inv_acc;
            l_record_t.open_total := c1.all_open_acc;
            l_record_t.pending_total := c1.all_pending_acc;
            l_record_t.close_total := c1.all_closed_acc;
            l_record_t.inv_total := c1.all_inv_acc;
            if c1.all_open_acc > 0 then
                l_record_t.open_perc := round((c1.open_acc / c1.all_open_acc) * 100, 2);
            else
                l_record_t.open_perc := 0;
            end if;

            if c1.all_pending_acc > 0 then
                l_record_t.pending_perc := round((c1.pending_acc / c1.all_pending_acc) * 100, 2);
            else
                l_record_t.pending_perc := 0;
            end if;

            if c1.all_closed_acc > 0 then
                l_record_t.close_perc := round((c1.closed_acc / c1.all_closed_acc) * 100, 2);
            else
                l_record_t.close_perc := 0;
            end if;

            if c1.all_inv_acc > 0 then
                l_record_t.inv_perc := round((c1.inv_acc / c1.all_inv_acc) * 100, 2);
            else
                l_record_t.inv_perc := 0;
            end if;

            pipe row ( l_record_t );
        end loop;
    end get_overview_summary;

    function get_feature_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return feature_t
        pipelined
        deterministic
    is

        l_record_t feature_row_t;
        cursor cur_feature is
        select
            get_card_count(p_entrp_id, p_division_code, p_month, p_year)            card_count,
            get_card_not_active_count(p_entrp_id, p_division_code, p_month, p_year) card_not_active,
            get_ben_count(p_entrp_id, p_division_code, p_month, p_year)             ben_count,
            get_active_user_count(p_entrp_id, p_division_code, p_month, p_year)     active_user_count,
            get_acc_email_count(p_entrp_id, p_division_code, p_month, p_year)       acc_email_account,
            get_all_acc_count(p_entrp_id, p_division_code, null)                    all_count
        from
            dual;

    begin
        for c1 in cur_feature loop
            if c1.all_count > 0 then
                l_record_t.card_count := c1.card_count;
                l_record_t.card_new_count := c1.card_not_active;
                l_record_t.ben_count := c1.ben_count;
                l_record_t.online_user_count := c1.active_user_count;
                l_record_t.email_user_count := c1.acc_email_account;
                l_record_t.card_perc := round(c1.card_count / c1.all_count, 2) * 100;

                l_record_t.card_new_perc := round(c1.card_not_active / c1.all_count, 2) * 100;

                l_record_t.ben_perc := round(c1.ben_count / c1.all_count, 2) * 100;

                l_record_t.online_user_perc := round(c1.active_user_count / c1.all_count, 2) * 100;

                l_record_t.email_user_perc := round(c1.acc_email_account / c1.all_count, 2) * 100;

                l_record_t.total_account := c1.all_count;
            else
                l_record_t.card_count := 0;
                l_record_t.card_new_count := 0;
                l_record_t.ben_count := 0;
                l_record_t.online_user_count := 0;
                l_record_t.email_user_count := 0;
                l_record_t.card_perc := 0;
                l_record_t.card_new_perc := 0;
                l_record_t.ben_perc := 0;
                l_record_t.online_user_perc := 0;
                l_record_t.email_user_perc := 0;
            end if;

            pipe row ( l_record_t );
        end loop;
    end get_feature_summary;

    function get_balance_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return balance_t
        pipelined
        deterministic
    is

        l_record_t balance_row_t;
        cursor cur_feature is
        select
            nvl(
                get_acc_balance(p_entrp_id, p_division_code, p_month, p_year),
                0
            ) acc_balance,
            nvl(
                get_acc_inv_bal(p_entrp_id, p_division_code, p_month, p_year),
                0
            ) outside_inv_balance,
            nvl(
                get_all_acc_count(p_entrp_id, p_division_code, null),
                0
            ) all_count
        from
            dual;

    begin
        for c1 in cur_feature loop
            if c1.all_count > 0 then
                l_record_t.acc_balance := round(c1.acc_balance / c1.all_count, 2);
                l_record_t.investment_balance := round(c1.outside_inv_balance / c1.all_count, 2);
                l_record_t.total_balance := round((c1.acc_balance + c1.outside_inv_balance) / c1.all_count, 2);

            else
                l_record_t.acc_balance := 0;
                l_record_t.investment_balance := 0;
                l_record_t.total_balance := 0;
            end if;

            pipe row ( l_record_t );
        end loop;
    end get_balance_summary;

    function get_balance_range (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return balance_range_t
        pipelined
        deterministic
    is

        l_record_t        balance_range_row_t;
        l_date            date := last_day(to_date('01-'
                                        || p_month
                                        || '-'
                                        || p_year, 'DD-MM-YYYY'));
        l_no_of_employees number;
        cursor cur_balance_range is
        with bal as (
            select
                acc_id,
                pc_account.new_acc_balance(acc_id, '01-JAN-2004', l_date, 'HSA') balance
            from
                person,
                account
            where
                    person.pers_id = account.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and person.entrp_id = p_entrp_id
        )
        select
            1             ord,
            'Negative'    description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance < 0
        union
        select
            2,
            '$0-$500'     description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance between 1 and 500
        union
        select
            3,
            '>$500-$1000' description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance between 501 and 1000
        union
        select
            4,
            '>$1,000 - $2,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 1001 and 2000
        union
        select
            5,
            '>$2,000 - $5,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 2001 and 5000
        union
        select
            6,
            '>$5,000 -$10,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 5001 and 10000
        union
        select
            7,
            '>$10,000'    description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance > 10000
        order by
            1;

    begin
        l_no_of_employees := get_all_acc_count(p_entrp_id, p_division_code, null, p_month, p_year);
        pc_log.log_error('get_balance_range', 'l_no_of_employees' || l_no_of_employees);
        for c1 in cur_balance_range loop
            pc_log.log_error('get_balance_range', 'c1.description' || c1.description);
            pc_log.log_error('get_balance_range', 'c1.c1.no_of_accounts' || c1.no_of_accounts);
            l_record_t.description := c1.description;
            l_record_t.no_of_accounts := nvl(c1.no_of_accounts, 0);
            l_record_t.total_amount := round(
                nvl(c1.total_amount, 0),
                2
            );

            if l_no_of_employees > 0 then
                l_record_t.perc_account := round((nvl(c1.no_of_accounts, 0) / l_no_of_employees) * 100,
                                                 2);
            else
                l_record_t.perc_account := 0;
                l_record_t.description := c1.description;
                l_record_t.no_of_accounts := 0;
                l_record_t.total_amount := 0;
            end if;

            pipe row ( l_record_t );
        end loop;

    end get_balance_range;

    function get_outside_inv_range (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return balance_range_t
        pipelined
        deterministic
    is

        l_record_t        balance_range_row_t;
        l_date            date := last_day(to_date('01-'
                                        || p_month
                                        || '-'
                                        || p_year, 'DD-MM-YYYY'));
        l_no_of_employees number;
        cursor cur_balance_range is
        with bal as (
            select
                acc_id,
                nvl(
                    pc_account.outside_inv_balance(acc_id, l_date),
                    0
                ) balance
            from
                person,
                account
            where
                    person.pers_id = account.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and person.entrp_id = p_entrp_id
                and nvl(
                    pc_account.outside_inv_balance(acc_id, l_date),
                    0
                ) > 0
        )
        select
            1             ord,
            'Negative'    description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance < 0
        union
        select
            2,
            '$0-$500'     description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance between 1 and 500
        union
        select
            3,
            '>$500-$1000' description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance between 501 and 1000
        union
        select
            4,
            '>$1,000 - $2,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 1001 and 2000
        union
        select
            5,
            '>$2,000 - $5,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 2001 and 5000
        union
        select
            6,
            '>$5,000 -$10,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 5001 and 10000
        union
        select
            7,
            '>$10,000'    description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance > 10000
        order by
            1;

    begin
        l_no_of_employees := get_all_acc_count(p_entrp_id, p_division_code, null, p_month, p_year);
        for c1 in cur_balance_range loop
            l_record_t.description := c1.description;
            l_record_t.no_of_accounts := nvl(c1.no_of_accounts, 0);
            l_record_t.total_amount := round(
                nvl(c1.total_amount, 0),
                2
            );

            if l_no_of_employees > 0 then
                l_record_t.perc_account := round((nvl(c1.no_of_accounts, 0) / l_no_of_employees) * 100,
                                                 2);
            else
                l_record_t.perc_account := 0;
                l_record_t.description := c1.description;
                l_record_t.no_of_accounts := 0;
                l_record_t.total_amount := 0;
            end if;

            pipe row ( l_record_t );
        end loop;

    end get_outside_inv_range;

    function get_total_bal_range (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return balance_range_t
        pipelined
        deterministic
    is

        l_record_t        balance_range_row_t;
        l_date            date := last_day(to_date('01-'
                                        || p_month
                                        || '-'
                                        || p_year, 'DD-MM-YYYY'));
        l_no_of_employees number;
        cursor cur_balance_range is
        with bal as (
            select
                acc_id,
                pc_account.new_acc_balance(acc_id, '01-JAN-2004', l_date, 'HSA') + pc_account.outside_inv_balance(acc_id, l_date) balance
            from
                person,
                account
            where
                    person.pers_id = account.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and person.entrp_id = p_entrp_id
        )
        select
            1             ord,
            'Negative'    description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance < 0
        union
        select
            2,
            '$0-$500'     description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance between 1 and 500
        union
        select
            3,
            '>$500-$1000' description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance between 501 and 1000
        union
        select
            4,
            '>$1,000 - $2,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 1001 and 2000
        union
        select
            5,
            '>$2,000 - $5,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 2001 and 5000
        union
        select
            6,
            '>$5,000 -$10,000' description,
            count(acc_id)      no_of_accounts,
            sum(balance)       total_amount
        from
            bal
        where
            balance between 5001 and 10000
        union
        select
            7,
            '>$10,000'    description,
            count(acc_id) no_of_accounts,
            sum(balance)  total_amount
        from
            bal
        where
            balance > 10000
        order by
            1;

    begin
        l_no_of_employees := get_all_acc_count(p_entrp_id, p_division_code, null, p_month, p_year);
        for c1 in cur_balance_range loop
            l_record_t.description := c1.description;
            l_record_t.no_of_accounts := c1.no_of_accounts;
            l_record_t.total_amount := round(c1.total_amount, 2);
            if l_no_of_employees > 0 then
                l_record_t.perc_account := round((c1.no_of_accounts / l_no_of_employees) * 100, 2);
            else
                l_record_t.perc_account := 0;
                l_record_t.description := c1.description;
                l_record_t.no_of_accounts := 0;
                l_record_t.total_amount := 0;
            end if;

            pipe row ( l_record_t );
        end loop;

    end get_total_bal_range;

    function get_contribution_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return transaction_t
        pipelined
        deterministic
    is

        l_record_t        transaction_row_t;
        l_date            date := last_day(to_date('01-'
                                        || p_month
                                        || '-'
                                        || p_year, 'DD-MM-YYYY'));
        l_no_of_employees number;
        cursor cur_contribution_summary is
        select
            'Employer Contributions'            description,
            sum(nvl(amount, 0))                 total_amount,
            count(acc_id)                       no_of_txns,
            sum(nvl(amount, 0)) / count(acc_id) avg_amount
        from
            income i
        where
                contributor = p_entrp_id
            and trunc(fee_date) between trunc(l_date, 'MM') and l_date
            and exists (
                select
                    1
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and ( p_division_code is null
                          or division_code = nvl(
                        get_dvsn_cd(p_division_code),
                        division_code
                    ) )
                    and acc_id = i.acc_id
            )
        union
        select
            'Employee Contributions'                  description,
            sum(nvl(amount_add, 0))                   total_amount,
            count(i.acc_id)                           no_of_txns,
            sum(nvl(amount_add, 0)) / count(i.acc_id) avg_amount
        from
            income  i,
            account a,
            person  p
        where
                i.acc_id = a.acc_id
            and a.pers_id = p.pers_id
            and nvl(amount_add, 0) <> 0
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and p.entrp_id = p_entrp_id
            and fee_code in ( 3, 4, 6, 7, 10 )
            and trunc(fee_date) between trunc(l_date, 'MM') and l_date
        union
        select
            'Total Payroll Contributions' description,
            sum(nvl(total_amount, 0))     total_amount,
            sum(nvl(no_of_txns, 0))       no_of_txns,
            sum(nvl(avg_amount, 0))       avg_amount
        from
            (
                select
                    sum(nvl(amount, 0))                 total_amount,
                    count(acc_id)                       no_of_txns,
                    sum(nvl(amount, 0)) / count(acc_id) avg_amount
                from
                    income i
                where
                        contributor = p_entrp_id
                    and trunc(fee_date) between trunc(l_date, 'MM') and l_date
                    and exists (
                        select
                            1
                        from
                            person  a,
                            account b
                        where
                                a.pers_id = b.pers_id
                            and ( p_division_code is null
                                  or division_code = nvl(
                                get_dvsn_cd(p_division_code),
                                division_code
                            ) )
                            and acc_id = i.acc_id
                    )
                union
                select
                    sum(nvl(amount_add, 0))                   total_amount,
                    count(i.acc_id)                           no_of_txns,
                    sum(nvl(amount_add, 0)) / count(i.acc_id) avg_amount
                from
                    income  i,
                    account a,
                    person  p
                where
                        i.acc_id = a.acc_id
                    and a.pers_id = p.pers_id
                    and ( p_division_code is null
                          or division_code = nvl(
                        get_dvsn_cd(p_division_code),
                        division_code
                    ) )
                    and p.entrp_id = p_entrp_id
                    and nvl(amount_add, 0) <> 0
                    and fee_code in ( 3, 4, 6, 7, 10 )
                    and trunc(fee_date) between trunc(l_date, 'MM') and l_date
            )
        union
        select
            'Non Payroll Contributions'                                description,
            sum(nvl(amount, 0) + nvl(amount_add, 0))                   total_amount,
            count(i.acc_id)                                            no_of_txns,
            sum(nvl(amount, 0) + nvl(amount_add, 0)) / count(i.acc_id) avg_amount
        from
            income  i,
            account a,
            person  p
        where
                i.acc_id = a.acc_id
            and a.pers_id = p.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and i.contributor is null
            and p.entrp_id = p_entrp_id
            and fee_code not in ( 3, 4, 6, 7, 8,
                                  10 )
            and trunc(fee_date) between trunc(l_date, 'MM') and l_date;

    begin
        for c1 in cur_contribution_summary loop
            l_record_t.description := c1.description;
            l_record_t.no_of_txns := nvl(c1.no_of_txns, 0);
            l_record_t.total_amount := round(
                nvl(c1.total_amount, 0),
                2
            );

            l_record_t.avg_amount := round(
                nvl(c1.avg_amount, 0),
                2
            );

            pipe row ( l_record_t );
        end loop;
    end get_contribution_summary;

    function get_ytd_contribution_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         in number default null,
        p_year          in number default null
    ) return transaction_t
        pipelined
        deterministic
    is

        l_record_t        transaction_row_t;
        l_no_of_employees number;
        l_date            date;
        cursor cur_contribution_summary (
            c_date in date
        ) is
        select
            'Employer Contributions'            description,
            sum(nvl(amount, 0))                 total_amount,
            count(acc_id)                       no_of_txns,
            sum(nvl(amount, 0)) / count(acc_id) avg_amount
        from
            income i
        where
                contributor = p_entrp_id
            and trunc(fee_date) between trunc(c_date, 'YYYY') and c_date
            and exists (
                select
                    1
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and ( p_division_code is null
                          or division_code = nvl(
                        get_dvsn_cd(p_division_code),
                        division_code
                    ) )
                    and acc_id = i.acc_id
            )
        union
        select
            'Employee Contributions'                  description,
            sum(nvl(amount_add, 0))                   total_amount,
            count(i.acc_id)                           no_of_txns,
            sum(nvl(amount_add, 0)) / count(i.acc_id) avg_amount
        from
            income  i,
            account a,
            person  p
        where
                i.acc_id = a.acc_id
            and a.pers_id = p.pers_id
            and nvl(amount_add, 0) <> 0
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and p.entrp_id = p_entrp_id
            and fee_code in ( 3, 4, 6, 7, 10 )
            and trunc(fee_date) between trunc(c_date, 'YYYY') and c_date
        union
        select
            'Total Payroll Contributions' description,
            sum(nvl(total_amount, 0))     total_amount,
            sum(nvl(no_of_txns, 0))       no_of_txns,
            sum(nvl(avg_amount, 0))       avg_amount
        from
            (
                select
                    sum(nvl(amount, 0))                 total_amount,
                    count(acc_id)                       no_of_txns,
                    sum(nvl(amount, 0)) / count(acc_id) avg_amount
                from
                    income i
                where
                        contributor = p_entrp_id
                    and trunc(fee_date) between trunc(c_date, 'YYYY') and c_date
                    and exists (
                        select
                            1
                        from
                            person  a,
                            account b
                        where
                                a.pers_id = b.pers_id
                            and ( p_division_code is null
                                  or division_code = nvl(
                                get_dvsn_cd(p_division_code),
                                division_code
                            ) )
                            and acc_id = i.acc_id
                    )
                union
                select
                    sum(nvl(amount_add, 0))                   total_amount,
                    count(i.acc_id)                           no_of_txns,
                    sum(nvl(amount_add, 0)) / count(i.acc_id) avg_amount
                from
                    income  i,
                    account a,
                    person  p
                where
                        i.acc_id = a.acc_id
                    and a.pers_id = p.pers_id
                    and nvl(amount_add, 0) <> 0
                    and ( p_division_code is null
                          or division_code = nvl(
                        get_dvsn_cd(p_division_code),
                        division_code
                    ) )
                    and p.entrp_id = p_entrp_id
                    and fee_code in ( 3, 4, 6, 7, 10 )
                    and trunc(fee_date) between trunc(c_date, 'YYYY') and c_date
            )
        union
        select
            'Non Payroll Contributions'                                description,
            sum(nvl(amount, 0) + nvl(amount_add, 0))                   total_amount,
            count(i.acc_id)                                            no_of_txns,
            sum(nvl(amount, 0) + nvl(amount_add, 0)) / count(i.acc_id) avg_amount
        from
            income  i,
            account a,
            person  p
        where
                i.acc_id = a.acc_id
            and a.pers_id = p.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and i.contributor is null
            and p.entrp_id = p_entrp_id
            and fee_code not in ( 3, 4, 6, 7, 8,
                                  10 )
            and trunc(fee_date) between trunc(c_date, 'YYYY') and c_date;

    begin
        if
            p_month is not null
            and p_year is not null
        then
            l_date := last_day(to_date('01-'
                                       || p_month
                                       || '-'
                                       || p_year, 'DD-MM-YYYY'));
        else
            l_date := sysdate;
        end if;

        for c1 in cur_contribution_summary(l_date) loop
            l_record_t.description := c1.description;
            l_record_t.no_of_txns := nvl(c1.no_of_txns, 0);
            l_record_t.total_amount := nvl(
                round(c1.total_amount, 2),
                0
            );

            l_record_t.avg_amount := nvl(
                round(c1.avg_amount, 2),
                0
            );

            pipe row ( l_record_t );
        end loop;

    end get_ytd_contribution_summary;

    function get_disbursement_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return transaction_t
        pipelined
        deterministic
    is

        l_record_t        transaction_row_t;
        l_no_of_employees number;
        l_date            date := last_day(to_date('01-'
                                        || p_month
                                        || '-'
                                        || p_year, 'DD-MM-YYYY'));
        cursor cur_claim_summary is
        select
            'Disbursement'                        description,
            count(a.acc_id)                       no_of_txns,
            sum(nvl(amount, 0))                   total_amount,
            sum(nvl(amount, 0)) / count(a.acc_id) avg_amount
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and c.pers_id = b.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and reason_code in ( 11, 12, 19, 13 )
            and c.entrp_id = p_entrp_id
            and trunc(pay_date) between trunc(l_date, 'MM') and l_date
        union
        select
            'Rollover',
            count(a.acc_id)                       no_of_txns,
            sum(nvl(amount, 0))                   total_amount,
            sum(nvl(amount, 0)) / count(a.acc_id) avg_amount
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and c.pers_id = b.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and reason_code = 120
            and c.entrp_id = p_entrp_id
            and trunc(pay_date) between trunc(l_date, 'MM') and l_date
        union
        select
            'Fees',
            count(a.acc_id)                       no_of_txns,
            sum(nvl(amount, 0))                   total_amount,
            sum(nvl(amount, 0)) / count(a.acc_id) avg_amount
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and c.pers_id = b.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and reason_code in ( 1, 2 )
            and c.entrp_id = p_entrp_id
            and trunc(pay_date) between trunc(l_date, 'MM') and l_date;

    begin
        for c1 in cur_claim_summary loop
            l_record_t.description := c1.description;
            l_record_t.no_of_txns := nvl(c1.no_of_txns, 0);
            l_record_t.total_amount := nvl(
                round(c1.total_amount, 2),
                0
            );

            l_record_t.avg_amount := nvl(
                round(c1.avg_amount, 2),
                0
            );

            pipe row ( l_record_t );
        end loop;
    end get_disbursement_summary;

    function get_ytd_disbursement_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         in number default null,
        p_year          in number default null
    ) return transaction_t
        pipelined
        deterministic
    is

        l_record_t        transaction_row_t;
        l_no_of_employees number;
        l_date            date;
        cursor cur_claim_summary (
            c_date in date
        ) is
        select
            'Disbursement'                        description,
            count(a.acc_id)                       no_of_txns,
            sum(nvl(amount, 0))                   total_amount,
            sum(nvl(amount, 0)) / count(a.acc_id) avg_amount
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and c.pers_id = b.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and reason_code in ( 11, 12, 19, 13 )
            and c.entrp_id = p_entrp_id
            and trunc(pay_date) between trunc(c_date, 'YYYY') and c_date
        union
        select
            'Rollover',
            count(a.acc_id)                       no_of_txns,
            sum(nvl(amount, 0))                   total_amount,
            sum(nvl(amount, 0)) / count(a.acc_id) avg_amount
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and c.pers_id = b.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and reason_code = 120
            and c.entrp_id = p_entrp_id
            and trunc(pay_date) between trunc(c_date, 'YYYY') and c_date
        union
        select
            'Fees',
            count(a.acc_id)                       no_of_txns,
            sum(nvl(amount, 0))                   total_amount,
            sum(nvl(amount, 0)) / count(a.acc_id) avg_amount
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and c.pers_id = b.pers_id
       --and nvl(division_code,'0')=nvl(get_dvsn_cd(p_division_code),nvl(division_code,'0'))
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and reason_code in ( 1, 2 )
            and c.entrp_id = p_entrp_id
            and trunc(pay_date) between trunc(c_date, 'YYYY') and c_date;

    begin
        if
            p_month is not null
            and p_year is not null
        then
            l_date := last_day(to_date('01-'
                                       || p_month
                                       || '-'
                                       || p_year, 'DD-MM-YYYY'));
        else
            l_date := sysdate;
        end if;

        for c1 in cur_claim_summary(l_date) loop
            l_record_t.description := c1.description;
            l_record_t.no_of_txns := nvl(c1.no_of_txns, 0);
            l_record_t.total_amount := nvl(
                round(c1.total_amount, 2),
                0
            );

            l_record_t.avg_amount := nvl(
                round(c1.avg_amount, 2),
                0
            );

            pipe row ( l_record_t );
        end loop;

    end get_ytd_disbursement_summary;

    function get_spender_saver_summary (
        p_entrp_id      in number,
        p_division_code varchar2,
        p_month         in number default null,
        p_year          in number default null
    ) return spend_save_t
        pipelined
        deterministic
    is

        l_total_acount number := 0;
        l_record_t     spend_save_row_t;
        l_date         date;
        cursor cur_spend_save (
            c_date date
        ) is
        with spend_save as (
            select
                acc_id,
                decode(cont, 0, 1, cont) cont,
                pay
            from
                (
                    select
                        b.acc_id,
                        nvl(
                            pc_account_details.get_receipts_total(b.acc_id,
                                                                  trunc(c_date, 'YYYY'),
                                                                  c_date,
                                                                  b.start_date),
                            0
                        ) cont,
                        nvl(
                            pc_account_details.get_disbursement_total(b.acc_id,
                                                                      trunc(c_date, 'YYYY'),
                                                                      c_date),
                            0
                        ) pay
                    from
                        account b,
                        person  c
                    where
                            c.pers_id = b.pers_id
                        and ( p_division_code is null
                              or division_code = nvl(
                            get_dvsn_cd(p_division_code),
                            division_code
                        ) )
                        and c.entrp_id = p_entrp_id
                )
        )
        select
            1                                   seq,
            'SPENDERS'                          txn_type,
            'Spent > 200% of YTD Contributions' description,
            count(*)                            no_of_accounts
        from
            spend_save
        where
            pay / cont >= 2
        union
        select
            2,
            'SPENDERS'                                  txn_type,
            'Spent   100% - 200% of YTD Contributions ' description,
            count(*)                                    no_of_accounts
        from
            spend_save
        where
                pay / cont >= 1
            and pay / cont < 2
        union
        select
            3,
            'PARTIAL_SPENDERS'                         txn_type,
            'Spent >50% - <100% of YTD Contributions ' description,
            count(*)                                   no_of_accounts
        from
            spend_save
        where
                pay / cont >=.5
            and pay / cont < 1
        union
        select
            4,
            'PARTIAL_SPENDERS'                       txn_type,
            'Spent >25% - 50% of YTD Contributions ' description,
            count(*)                                 no_of_accounts
        from
            spend_save
        where
                pay / cont >=.25
            and pay / cont <.5
        union
        select
            5,
            'PARTIAL_SPENDERS'                        txn_type,
            'Spent  >0% - 25% of YTD Contributions  ' description,
            count(*)                                  no_of_accounts
        from
            spend_save
        where
                pay / cont > 0
            and pay / cont <.25
        union
        select
            6,
            'SAVER'                          txn_type,
            'Spent 0% of YTD Contributions ' description,
            count(*)                         no_of_accounts
        from
            spend_save
        where
                pay = 0
            and cont > 0
        order by
            1;

    begin
        if
            p_month is not null
            and p_year is not null
        then
            l_date := last_day(to_date('01-'
                                       || p_month
                                       || '-'
                                       || p_year, 'DD-MM-YYYY'));
        else
            l_date := sysdate;
        end if;

        for x in (
            select
                count(b.acc_id) cnt
            from
                account b,
                person  c
            where
                    c.pers_id = b.pers_id
                and c.entrp_id = p_entrp_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
        ) loop
            l_total_acount := x.cnt;
        end loop;

        if l_total_acount = 0 then
            l_total_acount := 1;
        end if;
        for c1 in cur_spend_save(l_date) loop
            l_record_t.transaction_type := c1.txn_type;
            l_record_t.description := c1.description;
            l_record_t.no_of_txns := nvl(c1.no_of_accounts, 0);
            l_record_t.perc_of_txns := nvl(
                round(c1.no_of_accounts / l_total_acount, 4),
                0
            ) * 100;

            pipe row ( l_record_t );
        end loop;

    end get_spender_saver_summary;

    function get_disb_detail_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return disb_detail_t
        pipelined
        deterministic
    is

        l_total_acount     number := 0;
        l_record_t         disb_detail_row_t;
        l_date             date := last_day(to_date('01-'
                                        || p_month
                                        || '-'
                                        || p_year, 'DD-MM-YYYY'));
        l_total_no_of_txns number := 0;
        l_total_amount     number := 0;
        cursor cur_disb_detail (
            c_total_txns   number,
            c_total_acc    number,
            c_total_amount number
        ) is
        with disb_details as (
            select
                p.reason_code,
                no_of_acct,
                total_amount,
                no_of_transactions
            from
                (
                    select
                        reason_code,
                        count(distinct a.acc_id) no_of_acct,
                        sum(amount)              total_amount,
                        count(change_num)        no_of_transactions
                    from
                        payment a,
                        account b,
                        person  c
                    where
                            a.acc_id = b.acc_id
                        and b.pers_id = c.pers_id
                        and ( p_division_code is null
                              or division_code = nvl(
                            get_dvsn_cd(p_division_code),
                            division_code
                        ) )
                        and c.entrp_id = p_entrp_id
                        and trunc(pay_date) between trunc(l_date, 'MM') and l_date
                    group by
                        reason_code
                )          x,
                pay_reason p
            where
                x.reason_code (+) = p.reason_code
        )
        select
            1,
            'Check'                                             transaction_type,
            round(no_of_acct / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_no_of_txns,
            round((no_of_transactions / c_total_txns) * 100, 2) perc_of_txns,
            round(total_amount / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_txn_amount,
            round(total_amount / c_total_acc, 2)                avg_amt_per_acct,
            round((total_amount / c_total_amount) * 100, 2)     avg_perc
        from
            (
                select
                    sum(no_of_acct)         no_of_acct,
                    sum(no_of_transactions) no_of_transactions,
                    sum(total_amount)       total_amount
                from
                    disb_details
                where
                    reason_code in ( 11, 12 )
            )
        --  AND    NO_OF_ACCT IS NOT NULL
        union
        select
            2,
            'Debit Card Purchase',
            round(no_of_acct / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_no_of_txns,
            round((no_of_transactions / c_total_txns) * 100, 2) perc_of_txns,
            round(total_amount / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_txn_amount,
            round(total_amount / c_total_acc, 2)                avg_amt_per_acct,
            round((total_amount / c_total_amount) * 100, 2)     avg_perc
        from
            disb_details
        where
            reason_code = 13
        union
        select
            3,
            'Electronic Funds Transfer',
            round(no_of_acct / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_no_of_txns,
            round((no_of_transactions / c_total_txns) * 100, 2) perc_of_txns,
            round(total_amount / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_txn_amount,
            round(total_amount / c_total_acc, 2)                avg_amt_per_acct,
            round((total_amount / c_total_amount) * 100, 2)     avg_perc
        from
            disb_details
        where
            reason_code = 19
        order by
            1;

    begin
        l_total_acount := get_acc_count(p_entrp_id, p_division_code, p_month, p_year, 'ACTIVE');
        for x in (
            select
                count(a.change_num) total_txns,
                sum(a.amount)       total_amount
            from
                payment a,
                account b,
                person  c
            where
                    a.acc_id = b.acc_id
                and b.pers_id = c.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and c.entrp_id = p_entrp_id
                and a.reason_code in ( 11, 12, 13, 19 )
                and trunc(pay_date) between trunc(l_date, 'MM') and l_date
        ) loop
            l_total_no_of_txns := x.total_txns;
            l_total_amount := x.total_amount;
        end loop;

        if l_total_no_of_txns = 0 then
            l_total_no_of_txns := 1;
        end if;
        if l_total_amount = 0 then
            l_total_amount := 1;
        end if;
        if l_total_acount = 0 then
            l_total_acount := 1;
        end if;
        for c1 in cur_disb_detail(l_total_no_of_txns, l_total_acount, l_total_amount) loop
            l_record_t.transaction_type := c1.transaction_type;
            l_record_t.avg_no_of_txns := round(
                nvl(c1.avg_no_of_txns, 0),
                2
            );

            l_record_t.perc_of_txns := round(
                nvl(c1.perc_of_txns, 0),
                2
            );

            l_record_t.avg_amount := round(
                nvl(c1.avg_txn_amount, 0),
                2
            );

            l_record_t.avg_amount_per_acct := round(
                nvl(c1.avg_amt_per_acct, 0),
                2
            );

            l_record_t.perc_amount := round(
                nvl(c1.avg_perc, 0),
                2
            );

            pipe row ( l_record_t );
        end loop;

    end get_disb_detail_summary;

    function get_ytd_disb_detail_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         in number default null,
        p_year          in number default null
    ) return disb_detail_t
        pipelined
        deterministic
    is

        l_total_acount     number := 0;
        l_record_t         disb_detail_row_t;
        l_total_no_of_txns number := 0;
        l_total_amount     number := 0;
        l_date             date;
        cursor cur_disb_detail (
            c_total_txns   number,
            c_total_acc    number,
            c_total_amount number,
            c_date         date
        ) is
        with disb_details as (
            select
                p.reason_code,
                no_of_acct,
                total_amount,
                no_of_transactions
            from
                (
                    select
                        reason_code,
                        count(distinct a.acc_id) no_of_acct,
                        sum(amount)              total_amount,
                        count(change_num)        no_of_transactions
                    from
                        payment a,
                        account b,
                        person  c
                    where
                            a.acc_id = b.acc_id
                        and b.pers_id = c.pers_id
                        and ( p_division_code is null
                              or division_code = nvl(
                            get_dvsn_cd(p_division_code),
                            division_code
                        ) )
                        and c.entrp_id = p_entrp_id
                        and trunc(pay_date) between trunc(c_date, 'YYYY') and c_date
                    group by
                        reason_code
                )          x,
                pay_reason p
            where
                x.reason_code (+) = p.reason_code
        )
        select
            1,
            'Check'                                             transaction_type,
            round(no_of_acct / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_no_of_txns,
            round((no_of_transactions / c_total_txns) * 100, 2) perc_of_txns,
            round(total_amount / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_txn_amount,
            round(total_amount / c_total_acc, 2)                avg_amt_per_acct,
            round((total_amount / c_total_amount) * 100, 2)     avg_perc
        from
            (
                select
                    sum(no_of_acct)         no_of_acct,
                    sum(no_of_transactions) no_of_transactions,
                    sum(total_amount)       total_amount
                from
                    disb_details
                where
                    reason_code in ( 11, 12 )
            )
     --     AND    NO_OF_ACCT IS NOT NULL
        union
        select
            2,
            'Debit Card Purchase',
            round(no_of_acct / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_no_of_txns,
            round((no_of_transactions / c_total_txns) * 100, 2) perc_of_txns,
            round(total_amount / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_txn_amount,
            round(total_amount / c_total_acc, 2)                avg_amt_per_acct,
            round((total_amount / c_total_amount) * 100, 2)     avg_perc
        from
            disb_details
        where
            reason_code = 13
        union
        select
            3,
            'Electronic Funds Transfer',
            round(no_of_acct / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_no_of_txns,
            round((no_of_transactions / c_total_txns) * 100, 2) perc_of_txns,
            round(total_amount / decode(no_of_transactions, 0, 1, no_of_transactions),
                  2)                                            avg_txn_amount,
            round(total_amount / c_total_acc, 2)                avg_amt_per_acct,
            round((total_amount / c_total_amount) * 100, 2)     avg_perc
        from
            disb_details
        where
            reason_code = 19
        order by
            1;

    begin
        if
            p_month is not null
            and p_year is not null
        then
            l_date := last_day(to_date('01-'
                                       || p_month
                                       || '-'
                                       || p_year, 'DD-MM-YYYY'));
        else
            l_date := sysdate;
        end if;

        l_total_acount := get_all_acc_count(p_entrp_id, p_division_code, null);
        for x in (
            select
                count(a.change_num) total_txns,
                sum(a.amount)       total_amount
            from
                payment a,
                account b,
                person  c
            where
                    a.acc_id = b.acc_id
                and b.pers_id = c.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and c.entrp_id = p_entrp_id
                and a.reason_code in ( 11, 12, 13, 19 )
                and trunc(pay_date) between trunc(l_date, 'YYYY') and l_date
        ) loop
            l_total_no_of_txns := x.total_txns;
            l_total_amount := x.total_amount;
        end loop;

        if l_total_no_of_txns = 0 then
            l_total_no_of_txns := 1;
        end if;
        if l_total_amount = 0 then
            l_total_amount := 1;
        end if;
        if l_total_acount = 0 then
            l_total_acount := 1;
        end if;
        for c1 in cur_disb_detail(l_total_no_of_txns, l_total_acount, l_total_amount, l_date) loop
            l_record_t.transaction_type := c1.transaction_type;
            l_record_t.avg_no_of_txns := round(
                nvl(c1.avg_no_of_txns, 0),
                2
            );

            l_record_t.perc_of_txns := round(
                nvl(c1.perc_of_txns, 0),
                2
            );

            l_record_t.avg_amount := round(
                nvl(c1.avg_txn_amount, 0),
                2
            );

            l_record_t.avg_amount_per_acct := round(
                nvl(c1.avg_amt_per_acct, 0),
                2
            );

            l_record_t.perc_amount := round(
                nvl(c1.avg_perc, 0),
                2
            );

            pipe row ( l_record_t );
        end loop;

    end get_ytd_disb_detail_summary;

    function get_disb_breakdown_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         number,
        p_year          number
    ) return disb_breakdown_t
        pipelined
        deterministic
    is

        l_total_acount     number := 0;
        l_record_t         disb_breakdown_row_t;
        l_date             date := last_day(to_date('01-'
                                        || p_month
                                        || '-'
                                        || p_year, 'DD-MM-YYYY'));
        l_total_no_of_txns number := 0;
        l_total_amount     number := 0;
        cursor cur_disb_detail (
            c_total_txns number
        ) is
        select
            1,
            'Paid to Subscriber' transaction_type,
            count(change_num),
            round((count(change_num) / c_total_txns) * 100,
                  2)             perc_of_txns
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and b.pers_id = c.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and c.entrp_id = p_entrp_id
            and reason_code in ( 12, 13, 19 )
            and trunc(pay_date) between trunc(l_date, 'MM') and l_date
        union
        select
            2,
            'Paid to Provider',
            count(change_num),
            round((count(change_num) / c_total_txns) * 100,
                  2) perc_of_txns
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and b.pers_id = c.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and c.entrp_id = p_entrp_id
            and reason_code = 11
            and trunc(pay_date) between trunc(l_date, 'MM') and l_date
        order by
            1;

    begin
        for x in (
            select
                count(a.change_num) total_txns
            from
                payment a,
                account b,
                person  c
            where
                    a.acc_id = b.acc_id
                and b.pers_id = c.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and c.entrp_id = p_entrp_id
                and a.reason_code in ( 11, 12, 13, 19 )
                and trunc(pay_date) between trunc(l_date, 'MM') and l_date
        ) loop
            l_total_no_of_txns := x.total_txns;
        end loop;

        if l_total_no_of_txns > 0 then
            for c1 in cur_disb_detail(l_total_no_of_txns) loop
                l_record_t.transaction_type := c1.transaction_type;
                l_record_t.perc_of_txns := round(
                    nvl(c1.perc_of_txns, 0),
                    2
                );

                pipe row ( l_record_t );
            end loop;

        else
            pipe row ( l_record_t );
        end if;

    end get_disb_breakdown_summary;

    function get_ytd_disb_breakdown_summary (
        p_entrp_id      number,
        p_division_code varchar2,
        p_month         in number default null,
        p_year          in number default null
    ) return disb_breakdown_t
        pipelined
        deterministic
    is

        l_total_acount     number := 0;
        l_record_t         disb_breakdown_row_t;
        l_total_no_of_txns number := 0;
        l_total_amount     number := 0;
        l_date             date;
        cursor cur_disb_detail (
            c_total_txns number,
            c_date       in date
        ) is
        select
            1,
            'Paid to Subscriber' transaction_type
           -- ,COUNT(CHANGE_NUM) perc_of_txns
            ,
            round((count(change_num) / c_total_txns) * 100,
                  2)             perc_of_txns
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and b.pers_id = c.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and c.entrp_id = p_entrp_id
            and trunc(pay_date) between trunc(c_date, 'YYYY') and c_date
            and reason_code in ( 12, 13, 19 )
        union
        select
            2,
            'Paid to Provider'
        --   ,COUNT(CHANGE_NUM) perc_of_txns
            ,
            round((count(change_num) / c_total_txns) * 100,
                  2) perc_of_txns
        from
            payment a,
            account b,
            person  c
        where
                a.acc_id = b.acc_id
            and b.pers_id = c.pers_id
            and ( p_division_code is null
                  or division_code = nvl(
                get_dvsn_cd(p_division_code),
                division_code
            ) )
            and c.entrp_id = p_entrp_id
            and reason_code = 11
            and trunc(pay_date) between trunc(c_date, 'YYYY') and c_date
        order by
            1;

    begin
        if
            p_month is not null
            and p_year is not null
        then
            l_date := last_day(to_date('01-'
                                       || p_month
                                       || '-'
                                       || p_year, 'DD-MM-YYYY'));
        else
            l_date := sysdate;
        end if;

        for x in (
            select
                count(change_num) total_txns
            from
                payment a,
                account b,
                person  c
            where
                    a.acc_id = b.acc_id
                and b.pers_id = c.pers_id
                and ( p_division_code is null
                      or division_code = nvl(
                    get_dvsn_cd(p_division_code),
                    division_code
                ) )
                and c.entrp_id = p_entrp_id
                and a.reason_code in ( 11, 12, 13, 19 )
                and trunc(pay_date) between trunc(l_date, 'YYYY') and l_date
        ) loop
            l_total_no_of_txns := x.total_txns;
        end loop;

        if l_total_no_of_txns > 0 then
            for c1 in cur_disb_detail(l_total_no_of_txns, l_date) loop
                l_record_t.transaction_type := c1.transaction_type;
                l_record_t.perc_of_txns := round(
                    nvl(c1.perc_of_txns, 0),
                    2
                );

                pipe row ( l_record_t );
            end loop;
        else
            pipe row ( l_record_t );
        end if;

    end get_ytd_disb_breakdown_summary;

    function get_hra_fsa_active_plans return plans_t
        pipelined
        deterministic
    is
        l_record_t plans_row_t;
    begin
        for x in (
            select
                level,
                add_months(
                    trunc(to_date('01-JAN-2013'), 'MM'),
                    1 * level - 1
                )  start_date,
                last_day(add_months(
                    trunc(to_date('01-JAN-2013'), 'MM'),
                    1 * level - 1
                )) end_date
            from
                dual
            connect by
                level <= months_between(to_date('31-DEC-2013') + 1, to_date('01-JAN-2013'))
            order by
                end_date
        ) loop
            for xx in (
                select
                    acc_id -- HRA only
                    ,
                    'HRA' plan_type
                from
                    ben_plan_enrollment_setup x
                where
                    entrp_id is null
                    and ben_plan_id_main is not null
                    and plan_end_date > x.end_date
                    and effective_date between x.start_date and x.end_date
                    and ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                    and product_type = 'HRA'
                union all
                (
                    select
                        acc_id -- FSA Combo
                        ,
                        'FSA_COMBO'
                    from
                        ben_plan_enrollment_setup x
                    where
                        plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        and plan_end_date > x.end_date
                        and effective_date between x.start_date and x.end_date
                        and ( effective_end_date is null
                              or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'TRN', 'TP2', 'PKG', 'UA1' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                    union
                    select
                        acc_id -- FSA Combo
                        ,
                        'FSA_COMBO'
                    from
                        ben_plan_enrollment_setup x
                    where
                        plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        and plan_end_date > x.end_date
                        and effective_date between x.start_date and x.end_date
                        and ( effective_end_date is null
                              or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'TP2', 'LPF',
                                                   'TRN', 'PKG', 'UA1' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                    union
                    select
                        acc_id -- FSA Combo
                        ,
                        'FSA_COMBO'
                    from
                        ben_plan_enrollment_setup x
                    where
                        ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and plan_end_date > x.end_date
                        and effective_date between x.start_date and x.end_date
                        and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                    group by
                        acc_id
                    having
                        count(distinct plan_type) > 1
                )
                union all
                (
                    select
                        acc_id -- Transit  Combo
                        ,
                        'TRN_PKG'
                    from
                        ben_plan_enrollment_setup x
                    where
                        ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and plan_end_date > x.end_date
                        and effective_date between x.start_date and x.end_date
                        and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                        and not exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                  --  HAVING COUNT(DISTINCT plan_type) > 1
                    union
                    select
                        acc_id -- Transit  Combo
                        ,
                        'TRN_PKG'
                    from
                        ben_plan_enrollment_setup x
                    where
                        ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and plan_end_date > x.end_date
                        and effective_date between x.start_date and x.end_date
                        and plan_type in ( 'TRN', 'PKG', 'UA1' )
                        and not exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                        and not exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                    having
                        count(distinct plan_type) > 1
                )
                union all
                select
                    acc_id -- Individual plans
                    ,
                    plan_type
                from
                    ben_plan_enrollment_setup x
                where
                        (
                            select
                                count(distinct plan_type)
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                   'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        ) = 1
                    and plan_end_date > x.end_date
                    and effective_date between x.start_date and x.end_date
                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                       'PKG', 'UA1', 'TP2' )
            ) loop
                l_record_t.acc_id := xx.acc_id;
                l_record_t.plans := xx.plan_type;
                l_record_t.start_date := x.start_date;
                l_record_t.end_date := x.end_date;
                pipe row ( l_record_t );
            end loop;
        end loop;
    end get_hra_fsa_active_plans;

    function get_ex_hra_fsa_active_plans return plans_t
        pipelined
        deterministic
    is
        l_record_t plans_row_t;
    begin
        for x in (
            select
                level,
                add_months(
                    trunc(to_date('01-JAN-2013'), 'MM'),
                    1 * level - 1
                )  start_date,
                last_day(add_months(
                    trunc(to_date('01-JAN-2013'), 'MM'),
                    1 * level - 1
                )) end_date
            from
                dual
            connect by
                level <= months_between(to_date('31-DEC-2013') + 1, to_date('01-JAN-2013'))
            order by
                end_date
        ) loop
            for xx in (
                select
                    acc_id -- HRA only
                    ,
                    'HRA' plan_type
                from
                    ben_plan_enrollment_setup x
                where
                    entrp_id is null
                    and ben_plan_id_main is not null
                    and plan_end_date > x.end_date
                    and effective_date < '01-JAN-2013'
                    and ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                    and product_type = 'HRA'
                union all
                (
                    select
                        acc_id -- FSA Combo
                        ,
                        'FSA_COMBO'
                    from
                        ben_plan_enrollment_setup x
                    where
                        plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        and plan_end_date > x.end_date
                        and effective_date < '01-JAN-2013'
                        and ( effective_end_date is null
                              or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                    union
                    select
                        acc_id -- FSA Combo
                        ,
                        'FSA_COMBO'
                    from
                        ben_plan_enrollment_setup x
                    where
                        plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        and plan_end_date > x.end_date
                        and effective_date < '01-JAN-2013'
                        and ( effective_end_date is null
                              or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                   'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                    union
                    select
                        acc_id -- FSA Combo
                        ,
                        'FSA_COMBO'
                    from
                        ben_plan_enrollment_setup x
                    where
                        ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and plan_end_date > x.end_date
                        and effective_date < '01-JAN-2013'
                        and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                    group by
                        acc_id
                    having
                        count(distinct plan_type) > 1
                )
                union all
                (
                    select
                        acc_id -- Transit  Combo
                        ,
                        'TRN_PKG'
                    from
                        ben_plan_enrollment_setup x
                    where
                        ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and plan_end_date > x.end_date
                        and effective_date < '01-JAN-2013'
                        and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                        and not exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                  --  HAVING COUNT(DISTINCT plan_type) > 1
                    union
                    select
                        acc_id -- Transit  Combo
                        ,
                        'TRN_PKG'
                    from
                        ben_plan_enrollment_setup x
                    where
                        ( effective_end_date is null
                          or nvl(effective_end_date, plan_end_date) > x.end_date )
                        and plan_end_date > x.end_date
                        and effective_date < '01-JAN-2013'
                        and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                        and not exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                        and not exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        )
                    group by
                        acc_id
                    having
                        count(distinct plan_type) > 1
                )
                union all
                select
                    acc_id -- Individual plans
                    ,
                    plan_type
                from
                    ben_plan_enrollment_setup x
                where
                        (
                            select
                                count(distinct plan_type)
                            from
                                ben_plan_enrollment_setup a
                            where
                                    a.acc_id = x.acc_id
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                   'PKG', 'UA1', 'TP2' )
                                and ( effective_end_date is null
                                      or nvl(effective_end_date, plan_end_date) > x.end_date )
                        ) = 1
                    and plan_end_date > x.end_date
                    and effective_date < '01-JAN-2013'
                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                       'PKG', 'UA1', 'TP2' )
            ) loop
                l_record_t.acc_id := xx.acc_id;
                l_record_t.plans := xx.plan_type;
                l_record_t.start_date := x.start_date;
                l_record_t.end_date := x.end_date;
                pipe row ( l_record_t );
            end loop;
        end loop;
    end get_ex_hra_fsa_active_plans;

    function get_all_deposit_summary (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2
    ) return all_deposits_t
        pipelined
        deterministic
    is
        l_record_t all_deposits_row_t;
    begin
        for x in (
            select
                b.acc_num,
                to_char(check_date, 'mm/dd/yyyy')   check_date,
                a.check_amount,
                a.check_number,
                a.reason_code,
                pc_lookups.get_pay_type(a.pay_code) payment_method,
                ' Unposted Employer Transaction'    transaction_type,
                a.note,
                c.plan_name
            from
                employer_deposits a,
                account           b,
                plans             c
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and nvl(reason_code, -1) not in ( 11, 12 )
                and c.plan_sign = p_plan_sign
                and b.account_type = p_account_type
                and b.account_type not in ( 'FSA', 'HRA' )
                and trunc(a.check_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                b.acc_num,
                to_char(check_date, 'mm/dd/yyyy')   check_date,
                a.check_amount,
                a.check_number,
                a.reason_code,
                pc_lookups.get_pay_type(a.pay_code) payment_method,
                ' Unposted Employer Transaction'    transaction_type,
                a.note,
                c.plan_name
            from
                employer_deposits a,
                account           b,
                plans             c
            where
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and nvl(reason_code, -1) not in ( 11, 12 )
                and c.plan_sign = p_plan_sign
                and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_account_type
                and c.account_type in ( 'FSA', 'HRA' )
                and trunc(a.check_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                b.acc_num,
                to_char(fee_date, 'mm/dd/yyyy'),
                nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) check_amount,
                cc_number,
                fee_code,
                pc_lookups.get_pay_type(a.pay_code),
                'Individual Transaction',
                a.note,
                c.plan_name
            from
                income  a,
                account b,
                plans   c
            where
                contributor is null
                and a.acc_id = b.acc_id
                and c.plan_sign = p_plan_sign
                and b.plan_code = c.plan_code
                and b.account_type = p_account_type
                and b.account_type not in ( 'FSA', 'HRA' )
                and nvl(fee_code, -1) not in ( 11, 12 )
                and trunc(fee_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                b.acc_num,
                to_char(fee_date, 'mm/dd/yyyy'),
                nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) check_amount,
                cc_number,
                fee_code,
                pc_lookups.get_pay_type(a.pay_code),
                'Individual Transaction',
                a.note,
                c.plan_name
            from
                income  a,
                account b,
                plans   c
            where
                contributor is null
                and a.acc_id = b.acc_id
                and c.plan_sign = p_plan_sign
                and b.plan_code = c.plan_code
                and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_account_type
                and b.account_type in ( 'FSA', 'HRA' )
                and nvl(fee_code, -1) not in ( 11, 12 )
                and trunc(fee_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.check_date := x.check_date;
            l_record_t.check_amount := x.check_amount;
            l_record_t.check_number := x.check_number;
            l_record_t.payment_method := x.payment_method;
            l_record_t.transaction_type := x.transaction_type;
            l_record_t.note := x.note;
            l_record_t.reason_code := pc_lookups.get_fee_reason(x.reason_code);
            l_record_t.plan_name := x.plan_name;
            pipe row ( l_record_t );
        end loop;
    end get_all_deposit_summary;

    function get_all_fee_summary (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2
    ) return all_deposits_t
        pipelined
        deterministic
    is
        l_record_t all_deposits_row_t;
    begin
        for x in (
            select
                b.acc_num,
                to_char(a.check_date, 'mm/dd/yyyy') check_date,
                a.check_amount,
                to_char(a.check_number)             check_number,
                e.reason_name,
                null                                payment_method,
                'Employer Fees'                     transaction_type,
                a.note,
                c.plan_name
            from
                employer_payments a,
                pay_reason        e,
                account           b,
                plans             c
            where
                    a.reason_code <> 25
                and a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and e.reason_code = a.reason_code
                and e.reason_type = 'FEE'
                and b.account_type not in ( 'FSA', 'HRA' )
                and b.account_type = p_account_type
                and c.plan_sign = p_plan_sign
                and trunc(a.check_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                b.acc_num,
                to_char(d.check_date, 'mm/dd/yyyy') check_date,
                a.check_amount,
                to_char(a.check_number)             check_number,
                e.reason_name,
                null                                payment_method,
                'Employer Fees'                     transaction_type,
                a.note,
                c.plan_name
            from
                employer_payments a,
                pay_reason        e,
                account           b,
                plans             c,
                checks            d
            where
                    a.reason_code <> 25
                and d.entity_type = 'EMPLOYER_PAYMENTS'
                and d.entity_id = a.payment_register_id
                and a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and e.reason_code = a.reason_code
                and e.reason_type = 'FEE'
                and b.account_type in ( 'FSA', 'HRA' )
                and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_account_type
                and c.plan_sign = p_plan_sign
                and trunc(d.check_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                c.acc_num,
                to_char(
                    nvl(paid_date, pay_date),
                    'mm/dd/yyyy'
                )                 check_date,
                nvl(a.amount, 0)  amount,
                to_char(a.pay_num),
                b.reason_name,
                null,
                'Individual Fees' transaction_type,
                a.note,
                d.plan_name
            from
                payment    a,
                pay_reason b,
                account    c,
                plans      d
            where
                    a.reason_code = b.reason_code
                and a.acc_id = c.acc_id
                and c.plan_code = d.plan_code
                and c.account_type = p_account_type
                and c.account_type not in ( 'FSA', 'HRA' )
                and d.plan_sign = p_plan_sign
                and b.reason_type = 'FEE'
                and trunc(pay_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                c.acc_num,
                to_char(
                    nvl(paid_date, pay_date),
                    'mm/dd/yyyy'
                )                 check_date,
                nvl(a.amount, 0)  amount,
                to_char(a.pay_num),
                b.reason_name,
                null,
                'Individual Fees' transaction_type,
                a.note,
                d.plan_name
            from
                payment    a,
                pay_reason b,
                account    c,
                plans      d
            where
                    a.reason_code = b.reason_code
                and a.acc_id = c.acc_id
                and c.plan_code = d.plan_code
                and c.account_type in ( 'FSA', 'HRA' )
                and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_account_type
                and d.plan_sign = p_plan_sign
                and b.reason_type = 'FEE'
                and trunc(pay_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.check_date := x.check_date;
            l_record_t.check_amount := x.check_amount;
            l_record_t.check_number := x.check_number;
            l_record_t.payment_method := x.payment_method;
            l_record_t.transaction_type := x.transaction_type;
            l_record_t.note := x.note;
            l_record_t.reason_code := x.reason_name;
            l_record_t.plan_name := x.plan_name;
            pipe row ( l_record_t );
        end loop;
    end get_all_fee_summary;

    function get_all_payment_summary (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2
    ) return all_deposits_t
        pipelined
        deterministic
    is
        l_record_t all_deposits_row_t;
    begin
        for x in (
            select
                b.acc_num,
                to_char(a.check_date, 'mm/dd/yyyy') check_date,
                a.check_amount,
                to_char(a.check_number)             check_number,
                e.reason_name,
                null                                payment_method,
                'Employer Payments'                 transaction_type,
                a.note,
                c.plan_name
            from
                employer_payments a,
                pay_reason        e,
                account           b,
                plans             c--,CHECKS D /*sk Commented on 10/7/2019 this to include non check entries
            where   /* D.ENTITY_TYPE ='EMPLOYER_PAYMENTS'
                AND      D.ENTITY_ID = a.payment_register_id*/
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and e.reason_code = a.reason_code
                and e.reason_type <> 'FEE'
                and b.account_type = p_account_type
                and b.account_type not in ( 'FSA', 'HRA' )
                and c.plan_sign = p_plan_sign
                and trunc(a.check_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                b.acc_num,
                to_char(a.check_date, 'mm/dd/yyyy') check_date,
                a.check_amount,
                to_char(a.check_number)             check_number,
                e.reason_name,
                null                                payment_method,
                'Employer Payments'                 transaction_type,
                a.note,
                c.plan_name
            from
                employer_payments a,
                pay_reason        e,
                account           b,
                plans             c--,CHECKS D --sk Commented on 10/7/2019 this to include non check entries
            where    /*D.ENTITY_TYPE ='EMPLOYER_PAYMENTS'
                AND      D.ENTITY_ID = a.payment_register_id*/
                    a.entrp_id = b.entrp_id
                and b.plan_code = c.plan_code
                and e.reason_code = a.reason_code
                and e.reason_type <> 'FEE'
                and b.account_type in ( 'FSA', 'HRA' )
                and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_account_type
                and c.plan_sign = p_plan_sign
                and trunc(a.check_date) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                c.acc_num,
                to_char(
                    nvl(paid_date, pay_date),
                    'mm/dd/yyyy'
                )                     check_date,
                nvl(a.amount, 0)      amount,
                to_char(a.pay_num),
                b.reason_name,
                null,
                'Individual Payments' transaction_type,
                a.note,
                d.plan_name
            from
                payment    a,
                pay_reason b,
                account    c,
                plans      d
            where
                    a.reason_code = b.reason_code
                and a.acc_id = c.acc_id
                and c.plan_code = d.plan_code
                and c.account_type = p_account_type
                and c.account_type not in ( 'FSA', 'HRA' )
                and d.plan_sign = p_plan_sign
                and b.reason_type <> 'FEE'
                and trunc(nvl(paid_date, pay_date)) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
            union all
            select
                c.acc_num,
                to_char(
                    nvl(paid_date, pay_date),
                    'mm/dd/yyyy'
                )                     check_date,
                nvl(a.amount, 0)      amount,
                to_char(a.pay_num),
                b.reason_name,
                null,
                'Individual Payments' transaction_type,
                a.note,
                d.plan_name
            from
                payment    a,
                pay_reason b,
                account    c,
                plans      d
            where
                    a.reason_code = b.reason_code
                and a.acc_id = c.acc_id
                and c.plan_code = d.plan_code
                and c.account_type in ( 'FSA', 'HRA' )
                and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_account_type
                and d.plan_sign = p_plan_sign
                and b.reason_type <> 'FEE'
                and trunc(nvl(paid_date, pay_date)) between to_date(p_from_date, 'MM/DD/YYYY') and to_date(p_to_date, 'MM/DD/YYYY')
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.check_date := x.check_date;
            l_record_t.check_amount := x.check_amount;
            l_record_t.check_number := x.check_number;
            l_record_t.payment_method := x.payment_method;
            l_record_t.transaction_type := x.transaction_type;
            l_record_t.note := x.note;
            l_record_t.reason_code := x.reason_name;
            l_record_t.plan_name := x.plan_name;
            pipe row ( l_record_t );
        end loop;
    end get_all_payment_summary;

    procedure export_transaction (
        p_account_type     in varchar2,
        p_plan_sign        in varchar2,
        p_from_date        in varchar2,
        p_to_date          in varchar2,
        p_transaction_type in varchar2
    ) as

        f_lob          bfile := bfilename('REPORT_DIR',
                                 p_transaction_type
                                 || replace(p_from_date, '/')
                                 || ''
                                 || replace(p_to_date, '/')
                                 || '.csv');
        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_dest_blob    blob;
        l_source_bfile bfile := bfilename('REPORT_DIR',
                                          p_transaction_type
                                          || replace(p_from_date, '/')
                                          || ''
                                          || replace(p_to_date, '/')
                                          || '.csv');
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
    begin
        if p_transaction_type = 'Receipts' then
            select
                acc_num
                || ','
                || check_date
                || ','
                || check_amount
                || ','
                || check_number
                || ','
                || reason_code
                || ','
                || plan_name
                || ','
                || payment_method
                || ','
                || transaction_type
                || ','
                || note
            bulk collect
            into l_line_tbl
            from
                table ( pc_reports_pkg.get_all_deposit_summary(p_account_type, p_plan_sign, p_from_date, p_to_date) );

        end if;

        if p_transaction_type = 'Fees' then
            select
                acc_num
                || ','
                || check_date
                || ','
                || check_amount
                || ','
                || check_number
                || ','
                || reason_code
                || ','
                || plan_name
                || ','
                || payment_method
                || ','
                || transaction_type
                || ','
                || note
            bulk collect
            into l_line_tbl
            from
                table ( pc_reports_pkg.get_all_fee_summary(p_account_type, p_plan_sign, p_from_date, p_to_date) );

        end if;

        if p_transaction_type = 'Payments' then
            select
                acc_num
                || ','
                || check_date
                || ','
                || check_amount
                || ','
                || check_number
                || ','
                || reason_code
                || ','
                || plan_name
                || ','
                || payment_method
                || ','
                || transaction_type
                || ','
                || note
            bulk collect
            into l_line_tbl
            from
                table ( pc_reports_pkg.get_all_payment_summary(p_account_type, p_plan_sign, p_from_date, p_to_date) );

        end if;

        l_utl_id := utl_file.fopen('REPORT_DIR',
                                   p_transaction_type
                                   || replace(p_from_date, '/')
                                   || ''
                                   || replace(p_to_date, '/')
                                   || '.csv',
                                   'w');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => 'Account Number,Check Date,Check Amount,Check Number ,Reason Code,Plan Name,Payment Method,Transaction Type,Note'
        );
        for i in 1..l_line_tbl.count loop
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line_tbl(i)
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
        dbms_lob.createtemporary(l_dest_blob, true);
  /* Opening the source BFILE is mandatory */
        dbms_lob.fileopen(l_source_bfile, dbms_lob.file_readonly);
  /* Save the input source/destination offsets */
        l_src_osin := l_src_offset;
        l_dst_osin := l_dest_offset;
  /* Use LOBMAXSIZE to indicate loading the entire BFILE */
        dbms_lob.loadblobfromfile(l_dest_blob, l_source_bfile, dbms_lob.lobmaxsize, l_src_offset, l_dest_offset);
        owa_util.mime_header('application/octet', false);
        htp.p('Content-length: ' || dbms_lob.getlength(l_dest_blob));
        htp.p('Content-Disposition: attachment; filename="'
              || p_transaction_type
              || replace(p_from_date, '/')
              || ''
              || replace(p_to_date, '/')
              || '.csv'
              || '"');

        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_transaction;

    function get_hra_sfhso_exp_funds_rep return expire_funds_t
        pipelined
        deterministic
    is
        l_record_t expire_funds_row;
    begin
        for x in (
            select
                b.acc_num
            from
                ben_plan_enrollment_setup a,
                account                   b
            where
                    sf_ordinance_flag = 'Y'
                and ben_plan_id_main is not null
                and a.acc_id = b.acc_id
                and b.account_type in ( 'HRA', 'FSA' )
                and b.entrp_id is null
                and a.effective_end_date is null
                and a.product_type = 'HRA'
        ) loop
            l_record_t.acc_num := x.acc_num;
            for xx in (
                select
                    expired_funds,
                    expiration_date
                from
                    table ( pc_reports_pkg.get_hra_sfhso_contribution(x.acc_num) )
                where
                        expiration_date <= sysdate
                    and expired_funds > 0
            ) loop
                l_record_t.expired_amount := xx.expired_funds;
                l_record_t.expiration_date := xx.expiration_date;
                pipe row ( l_record_t );
            end loop;

        end loop;
    end get_hra_sfhso_exp_funds_rep;

    function get_hra_sfhso_contribution (
        p_acc_num in varchar2
    ) return contribution_t
        pipelined
        deterministic
    is

        l_disb_contrib_tbl       dibursement_t;
        l_contribution_tbl       contribution_t;
        l_rollover_tbl           contribution_t;
        l_record_t               contribution_row;
        l_total_disbursed_amount number := 0;
        l_total_cont_amount      number := 0;
        l_remaining_claim        number := 0;
        l_remaining_balance      number := 0;
    begin
        select
            disbursed,
            fee_date,
            next_fee_date,
            expiration_date,
            pc_fin.is_rolled_over(acc_id, fee_date) rollved_over
        bulk collect
        into l_disb_contrib_tbl
        from
            (
                select
                    nvl(
                        pc_fin.disbursement_ytd(acc_id,
                                                account_type,
                                                plan_type,
                                                null,
                                                fee_date,
                                                nvl(next_fee_date, sysdate)),
                        0
                    ) disbursed,
                    amount,
                    acc_id,
                    fee_date,
                    next_fee_date,
                    expiration_date
                from
                    (
                        select
                            a.acc_id,
                            a.fee_date,
                            lead(a.fee_date, 1)
                            over(
                                order by
                                    fee_date
                            ) - 1                                   next_fee_date,
                            add_months(a.fee_date, 24)              expiration_date,
                            nvl(a.amount, 0) + nvl(a.amount_add, 0) amount,
                            plan_type,
                            account_type
                        from
                            income  a,
                            account b
                        where
                                a.acc_id = b.acc_id
                            and plan_type is not null
                            and nvl(a.amount, 0) + nvl(a.amount_add, 0) > 0
                            and exists (
                                select
                                    *
                                from
                                    lookups
                                where
                                        lookup_name = 'FSA_HRA_PRODUCT_MAP'
                                    and lookup_code = a.plan_type
                                    and meaning = 'HRA'
                            )
                            and b.acc_num = p_acc_num
                            and a.fee_date > (
                                select
                                    min(plan_start_date) - 1
                                from
                                    ben_plan_enrollment_setup x
                                where
                                        x.acc_id = b.acc_id
                                    and a.plan_type = x.plan_type
                                    and x.sf_ordinance_flag = 'Y'
                            )
                            and nvl(fee_code, -1) <> 12
                        order by
                            trunc(fee_date) asc
                    )
            )
        where
            disbursed <> 0;

        if l_disb_contrib_tbl.count = 0 then
            select
                amount,
                0,
                acc_id,
                plan_type,
                account_type,
                fee_date,
                next_fee_date,
                expiration_date,
                reason_name,
                rollved_over,
                0,
                amount,
                0
            bulk collect
            into l_contribution_tbl
            from
                (
                    select
                        amount,
                        fee_date,
                        next_fee_date,
                        expiration_date,
                        case
                            when expiration_date > sysdate then
                                0
                            else
                                amount
                        end                    expired_funds,
                        acc_id,
                        plan_type,
                        account_type,
                        reason_name,
                        nvl(rollved_over, 'N') rollved_over
                    from
                        (
                            select
                                a.acc_id,
                                a.fee_date,
                                lead(a.fee_date, 1)
                                over(
                                    order by
                                        fee_date
                                ) - 1                                       next_fee_date,
                                add_months(a.fee_date, 24)                  expiration_date,
                                nvl(a.amount, 0) + nvl(a.amount_add, 0)     amount,
                                pc_fin.is_rolled_over(a.acc_id, a.fee_date) rollved_over,
                                plan_type,
                                account_type,
                                pc_lookups.get_fee_reason(a.fee_code)       reason_name
                            from
                                income  a,
                                account b
                            where
                                    a.acc_id = b.acc_id
                                and plan_type is not null
                                and exists (
                                    select
                                        *
                                    from
                                        lookups
                                    where
                                            lookup_name = 'FSA_HRA_PRODUCT_MAP'
                                        and lookup_code = a.plan_type
                                        and meaning = 'HRA'
                                )
                                and b.acc_num = p_acc_num
                                and nvl(a.amount, 0) + nvl(a.amount_add, 0) > 0
                                and a.fee_date > (
                                    select
                                        min(plan_start_date) - 1
                                    from
                                        ben_plan_enrollment_setup x
                                    where
                                            x.acc_id = b.acc_id
                                        and a.plan_type = x.plan_type
                                        and x.sf_ordinance_flag = 'Y'
                                )
                                and nvl(fee_code, -1) <> 12
                            order by
                                trunc(fee_date) asc
                        )
                );

        else
            select
                amount,
                nvl(
                    pc_fin.disbursement_ytd(acc_id,
                                            account_type,
                                            plan_type,
                                            null,
                                            fee_date,
                                            nvl(next_fee_date, sysdate)),
                    0
                ),
                acc_id,
                plan_type,
                account_type,
                fee_date,
                next_fee_date,
                expiration_date,
                reason_name,
                nvl(rollved_over, 'N') rollved_over,
                0                      claim_amount,
                amount,
                0                      expired_funds
            bulk collect
            into l_contribution_tbl
            from
                (
                    select
                        a.acc_id,
                        a.fee_date,
                        lead(a.fee_date, 1)
                        over(
                            order by
                                fee_date
                        ) - 1                                       next_fee_date,
                        add_months(a.fee_date, 24)                  expiration_date,
                        nvl(a.amount, 0) + nvl(a.amount_add, 0)     amount,
                        pc_fin.is_rolled_over(a.acc_id, a.fee_date) rollved_over,
                        plan_type,
                        account_type,
                        pc_lookups.get_fee_reason(a.fee_code)       reason_name
                    from
                        income  a,
                        account b
                    where
                            a.acc_id = b.acc_id
                        and plan_type is not null
                        and exists (
                            select
                                *
                            from
                                lookups
                            where
                                    lookup_name = 'FSA_HRA_PRODUCT_MAP'
                                and lookup_code = a.plan_type
                                and meaning = 'HRA'
                        )
                        and b.acc_num = p_acc_num--'FSA007140'
                        and nvl(a.amount, 0) + nvl(a.amount_add, 0) > 0
                        and a.fee_date > (
                            select
                                min(plan_start_date) - 1
                            from
                                ben_plan_enrollment_setup x
                            where
                                    x.acc_id = b.acc_id
                                and a.plan_type = x.plan_type
                                and x.sf_ordinance_flag = 'Y'
                        )
                        and nvl(fee_code, -1) <> 12
                    order by
                        trunc(fee_date) asc
                );

        end if;

        select
            amount,
            0,
            acc_id,
            plan_type,
            account_type,
            fee_date,
            next_fee_date,
            expiration_date,
            reason_name,
            rollved_over,
            0,
            amount,
            0
        bulk collect
        into l_rollover_tbl
        from
            (
                select
                    amount,
                    fee_date,
                    next_fee_date,
                    expiration_date,
                    case
                        when expiration_date > sysdate then
                            0
                        else
                            amount
                    end                    expired_funds,
                    acc_id,
                    plan_type,
                    account_type,
                    reason_name,
                    nvl(rollved_over, 'N') rollved_over
                from
                    (
                        select
                            a.acc_id,
                            a.fee_date,
                            lead(a.fee_date, 1)
                            over(
                                order by
                                    fee_date
                            ) - 1                                       next_fee_date,
                            add_months(a.fee_date, 24)                  expiration_date,
                            nvl(a.amount, 0) + nvl(a.amount_add, 0)     amount,
                            pc_fin.is_rolled_over(a.acc_id, a.fee_date) rollved_over,
                            plan_type,
                            account_type,
                            pc_lookups.get_fee_reason(a.fee_code)       reason_name
                        from
                            income  a,
                            account b
                        where
                                a.acc_id = b.acc_id
                            and plan_type is not null
                            and exists (
                                select
                                    *
                                from
                                    lookups
                                where
                                        lookup_name = 'FSA_HRA_PRODUCT_MAP'
                                    and lookup_code = a.plan_type
                                    and meaning = 'HRA'
                            )
                            and b.acc_num = p_acc_num
                            and nvl(a.amount, 0) + nvl(a.amount_add, 0) < 0
                            and a.fee_date > (
                                select
                                    min(plan_start_date) - 1
                                from
                                    ben_plan_enrollment_setup x
                                where
                                        x.acc_id = b.acc_id
                                    and a.plan_type = x.plan_type
                                    and x.sf_ordinance_flag = 'Y'
                            )
                            and nvl(fee_code, -1) <> 12
                        order by
                            trunc(fee_date) asc
                    )
            );

        if l_disb_contrib_tbl.count > 0 then
            << outer >> for i in 1..l_disb_contrib_tbl.count loop
                l_remaining_claim := l_disb_contrib_tbl(i).claim_amount;
                << inner >> for j in 1..l_contribution_tbl.count loop
                    if
                        l_disb_contrib_tbl(i).fee_date <= l_contribution_tbl(j).expiration_date
                        and l_remaining_claim > 0
                        and l_disb_contrib_tbl(i).rolled_over = l_contribution_tbl(j).rolled_over
                    then
                        if nvl(l_disb_contrib_tbl(i).next_fee_date,
                               sysdate) <= l_contribution_tbl(j).expiration_date then
                     -- pc_log.log_error ('SFORD',' l_contribution_tbl('||j||').remaining_balance '||l_contribution_tbl(j).remaining_balance);

                            if
                                l_contribution_tbl(j).remaining_balance > 0
                                and l_contribution_tbl(j).remaining_balance > l_remaining_claim
                            then
                            -- 250 > 49.86
                                l_contribution_tbl(j).remaining_balance := l_contribution_tbl(j).remaining_balance - l_remaining_claim
                                ;
                                l_contribution_tbl(j).claim_amount := l_contribution_tbl(j).claim_amount + l_remaining_claim;
                                l_remaining_claim := 0;
                          --  EXIT inner WHEN l_remaining_claim = 0;
                            -- 189.14
                            end if;
                      -- 189.14 < 489.14
                            if
                                l_contribution_tbl(j).remaining_balance > 0
                                and l_remaining_claim > 0
                                and l_contribution_tbl(j).remaining_balance < l_remaining_claim
                            then
                                l_contribution_tbl(j).claim_amount := l_contribution_tbl(j).claim_amount + l_contribution_tbl(j).remaining_balance
                                ;

                                l_remaining_claim := l_remaining_claim - l_contribution_tbl(j).remaining_balance;
                                l_contribution_tbl(j).remaining_balance := 0;
                            end if;

                        else
                            l_total_disbursed_amount := nvl(
                                pc_fin.disbursement_ytd(l_contribution_tbl(j).acc_id,
                                                        l_contribution_tbl(j).account_type,
                                                        l_contribution_tbl(j).plan_type,
                                                        null,
                                                        l_disb_contrib_tbl(i).fee_date,
                                                        l_contribution_tbl(j).expiration_date),
                                0
                            );

                            if
                                l_contribution_tbl(j).remaining_balance > 0
                                and l_contribution_tbl(j).remaining_balance > l_total_disbursed_amount
                            then
                            -- 250 > 49.86
                                l_contribution_tbl(j).remaining_balance := l_contribution_tbl(j).remaining_balance - l_total_disbursed_amount
                                ;
                                l_remaining_claim := l_remaining_claim - l_total_disbursed_amount;
                                l_contribution_tbl(j).claim_amount := l_contribution_tbl(j).claim_amount + l_total_disbursed_amount;

                          --  EXIT inner WHEN l_remaining_claim = 0;
                            -- 189.14
                            end if;

                            if
                                l_contribution_tbl(j).remaining_balance > 0
                                and l_remaining_claim > 0
                                and l_contribution_tbl(j).remaining_balance < l_remaining_claim
                            then
                                l_remaining_claim := l_remaining_claim - l_contribution_tbl(j).remaining_balance;
                                l_contribution_tbl(j).claim_amount := l_contribution_tbl(j).claim_amount + l_contribution_tbl(j).remaining_balance
                                ;

                                l_contribution_tbl(j).remaining_balance := 0;
                            end if;
                      -- 189.14 < 489.14
                        end if;

                    end if;
                end loop;

            end loop;
        end if;

        for i in 1..l_contribution_tbl.count loop
            l_record_t.contribution_amount := l_contribution_tbl(i).contribution_amount;
            l_record_t.disbursed_amount := l_contribution_tbl(i).disbursed_amount;
      --   l_record_t.disbursed_row                 :=  l_contribution_tbl(i).disbursed_row;
            l_record_t.fee_date := l_contribution_tbl(i).fee_date;
            l_record_t.next_fee_date := l_contribution_tbl(i).next_fee_date;
            l_record_t.claim_amount := l_contribution_tbl(i).claim_amount;
            l_record_t.fee_reason := l_contribution_tbl(i).fee_reason;
            l_record_t.acc_id := l_contribution_tbl(i).acc_id;
            l_record_t.plan_type := l_contribution_tbl(i).plan_type;
            l_record_t.account_type := l_contribution_tbl(i).account_type;
            l_record_t.rolled_over := l_contribution_tbl(i).rolled_over;
            if l_contribution_tbl(i).rolled_over = 'Y' then
                l_record_t.remaining_balance := 0;
                l_record_t.expiration_date := pc_fin.get_rollover_date(l_contribution_tbl(i).acc_id,
                                                                       l_contribution_tbl(i).fee_date);

                l_record_t.expired_funds := 0;
            else
                l_record_t.remaining_balance := l_contribution_tbl(i).remaining_balance;
                l_record_t.expiration_date := l_contribution_tbl(i).expiration_date;
                if l_contribution_tbl(i).expiration_date < sysdate then
                    l_record_t.expired_funds := l_record_t.remaining_balance;
                else
                    l_record_t.expired_funds := 0;
                end if;

            end if;

            l_remaining_balance := l_record_t.remaining_balance;
            pipe row ( l_record_t );
        end loop;

        for i in 1..l_rollover_tbl.count loop
            l_record_t.contribution_amount := l_rollover_tbl(i).contribution_amount;
            l_record_t.disbursed_amount := 0;
      --   l_record_t.disbursed_row                 :=  l_contribution_tbl(i).disbursed_row;
            l_record_t.fee_date := l_rollover_tbl(i).fee_date;
            l_record_t.next_fee_date := l_rollover_tbl(i).next_fee_date;
            l_record_t.claim_amount := 0;
            l_record_t.fee_reason := l_rollover_tbl(i).fee_reason;
            l_record_t.acc_id := l_rollover_tbl(i).acc_id;
            l_record_t.plan_type := l_rollover_tbl(i).plan_type;
            l_record_t.account_type := l_rollover_tbl(i).account_type;
            l_record_t.rolled_over := 'Y';
            l_record_t.expiration_date := l_rollover_tbl(i).fee_date;
            l_record_t.remaining_balance := 0;
            l_record_t.expired_funds := 0;
            pipe row ( l_record_t );
        end loop;

    end get_hra_sfhso_contribution;

    function get_benefit_plans (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return plan_info_t
        pipelined
        deterministic
    is
        l_record_t plan_info_row;
    begin
        pc_log.log_error('pc_reports_pkg.get_benefit_plans entrp_id', p_entrp_id);
        if
            p_plan_start_date is null
            and p_plan_end_date is null
        then
            for x in (
                select
                    *
                from
                    fsa_hra_er_ben_plans_v
                where
                        entrp_id = p_entrp_id
                    and plan_end_date > sysdate
                    and plan_type <> 'NDT'
            ) --Ticket#2739
             loop
                l_record_t.ben_plan_id := x.ben_plan_id;
                l_record_t.plan_type := x.plan_type;
                l_record_t.plan_type_meaning := x.plan_type_meaning;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                pipe row ( l_record_t );
            end loop;

        else
            for x in (
                select
                    *
                from
                    fsa_hra_er_ben_plans_v
                where
                        entrp_id = p_entrp_id
                    and plan_start_date = p_plan_start_date
                    and plan_end_date = p_plan_end_date
                    and plan_type <> 'NDT'
            )--Ticket#2739
             loop
                l_record_t.ben_plan_id := x.ben_plan_id;
                l_record_t.plan_type := x.plan_type;
                l_record_t.plan_type_meaning := x.plan_type_meaning;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                pipe row ( l_record_t );
            end loop;
        end if;

    end get_benefit_plans;

    function get_claims (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2,
        p_report_type     in varchar2
    ) return claim_t
        pipelined
        deterministic
    is
        l_record_t claim_row;
    begin
        if p_report_type in ( 'CLAIM_REPORT', 'CLAIM_REPORT_BY_TYPE' ) then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(pay_date, 'mm/dd/yyyy') pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    check_number,
                    claim_amount,
                    transaction_number,
                    reimbursement_method,
                    division_code,
                    division_name,
                    reason_code,
                    service_type,
                    service_type_meaning,
                    denied_amount,
                    plan_start_date,
                    plan_end_date
                from
                    claim_report_online_v
                where
                        entrp_id = p_entrp_id
                    and trunc(plan_start_date) >= p_plan_start_date
                    and trunc(plan_end_date) <= p_plan_end_date
                    and service_type = nvl(p_plan_type, service_type)
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
                union all
                        /* Ticket 3674.Display Fully Denied Claims */
                select
                    c.acc_num,
                    first_name,
                    last_name,
                    null                                         pay_date,
                    b.approved_amount,
                    b.claim_pending,
                    null                                         check_amount,
                    null                                         check_number,
                    to_number(b.claim_amount)                    claim_amount,
                    b.claim_id                                   transaction_number,
                    null                                         reimbursement_method,
                    pc_person.get_division_code(b.pers_id)       division_code,
                    pc_person.get_division_name(b.pers_id)       division_name,
                    0                                            reason_code,
                    b.service_type                               service_type,
                    pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
                    b.denied_amount,
                    b.plan_start_date,
                    b.plan_end_date
                from
                    payment_register a,
                    claimn           b,
                    account          c,
                    person           e
                where
                        a.entrp_id = b.entrp_id
                    and e.entrp_id = b.entrp_id  /*Ebtrp ID is mapped at Enterprise level */
                    and a.claim_id = b.claim_id
                    and e.pers_id = b.pers_id
                    and c.pers_id = b.pers_id  ---New
                    and b.claim_status = 'DENIED'
                    and b.entrp_id = p_entrp_id
                    and b.claim_status not in ( 'ERROR', 'CANCELLED' )
                    and trunc(claim_date) >= p_plan_start_date
                    and trunc(claim_date) <= p_plan_end_date
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.pay_date := x.pay_date;
                l_record_t.approved_amount := x.approved_amount;
                l_record_t.claim_pending := x.claim_pending;
                l_record_t.check_amount := x.check_amount;
                l_record_t.check_number := x.check_number;
                l_record_t.claim_amount := x.claim_amount;
                l_record_t.transaction_number := x.transaction_number;
                l_record_t.reimbursement_method := x.reimbursement_method;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;
                l_record_t.reason_code := x.reason_code;
                l_record_t.service_type := x.service_type;
                l_record_t.service_type_meaning := x.service_type_meaning;
                l_record_t.denied_amount := x.denied_amount;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.substantiated_flag := 'Yes';
                l_record_t.remaining_offset_amt := 0;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                pipe row ( l_record_t );
            end loop;
        end if;

        if p_report_type = 'ALL_CLAIMS_REPORT' then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(pay_date, 'mm/dd/yyyy')         pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    check_number,
                    to_number(claim_amount)                 claim_amount,
                    transaction_number,
                    reimbursement_method,
                    to_char(reason_code)                    reason_code,
                    service_type_meaning,
                    to_char(plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(plan_end_date, 'MM/DD/YYYY') plan_year,
                    service_type                            plan_type,
                    division_name,
                    division_code,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(transaction_date, 'mm/dd/yyyy') claim_date,
                    'Yes'                                   substantiated
                from
                    claim_report_online_v
                where
                        entrp_id = p_entrp_id
                    and reason_code <> 73
                    and trunc(pay_date) >= p_start_date
                    and trunc(pay_date) <= p_end_date
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
                union all
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(paid_date, 'mm/dd/yyyy')        pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    null,
                    to_number(claim_amount)                 claim_amount,
                    claim_id,
                    pc_lookups.get_reason_name(reason_code) --'Debit Card'
                    ,
                    to_char(reason_code) --13
                    ,
                    service_type_meaning,
                    to_char(plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(plan_end_date, 'MM/DD/YYYY') plan_year,
                    service_type,
                    division_name,
                    division_code,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(claim_date, 'mm/dd/yyyy')       claim_date,
                    decode(
                        nvl(substantiated, 'Y'),
                        'Y',
                        'Yes',
                        'No'
                    )
                from
                    hrafsa_debit_card_claims_v
                where
                        entrp_id = p_entrp_id
                    and trunc(claim_date) >= p_start_date
                    and trunc(claim_date) <= p_end_date
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
	                 /* Added for Ticket 3674*/
                union all
                select
                    c.acc_num,
                    first_name,
                    last_name,
                    null                                         pay_date,
                    b.approved_amount,
                    b.claim_pending,
                    null                                         check_amount,
                    null                                         check_number,
                    to_number(b.claim_amount)                    claim_amount,
                    b.claim_id                                   transaction_number,
                    null                                         reimbursement_method,
                    to_char(0)                                   reason_code,
                    pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
                    to_char(b.plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(b.plan_end_date, 'MM/DD/YYYY')    plan_year,
                    b.service_type                               plan_type,
                    pc_person.get_division_name(b.pers_id)       division_name,
                    pc_person.get_division_code(b.pers_id)       division_code,
                    b.denied_amount,
                    b.plan_start_date,
                    b.plan_end_date,
                    to_char(b.claim_date, 'mm/dd/yyyy')          claim_date,
                    'Yes'                                        substantiated
                from
                    payment_register a,
                    claimn           b,
                    account          c,
                    person           e
                where
                        a.entrp_id = b.entrp_id
                    and e.entrp_id = b.entrp_id
                    and a.claim_id = b.claim_id
                    and e.pers_id = b.pers_id
                    and c.pers_id = b.pers_id
                    and b.claim_status = 'DENIED'
                    and b.entrp_id = p_entrp_id
                    and b.claim_status not in ( 'ERROR', 'CANCELLED' )
                    and trunc(claim_date) >= p_start_date
                    and trunc(claim_date) <= p_end_date
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.pay_date := x.pay_date;
                l_record_t.approved_amount := x.approved_amount;
                l_record_t.claim_pending := x.claim_pending;
                l_record_t.check_amount := x.check_amount;
                l_record_t.check_number := x.check_number;
                l_record_t.claim_amount := x.claim_amount;
                l_record_t.transaction_number := x.transaction_number;
                l_record_t.reimbursement_method := x.reimbursement_method;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;
                l_record_t.reason_code := x.reason_code;
                l_record_t.service_type := x.plan_type;
                l_record_t.denied_amount := x.denied_amount;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.service_type_meaning := x.service_type_meaning;
                l_record_t.plan_year := x.plan_year;
                if x.substantiated in ( 'N', 'No' ) then
                    l_record_t.remaining_offset_amt := pc_claim.get_remaining_offset(x.transaction_number);
                end if;

                l_record_t.substantiated_flag := x.substantiated;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                pipe row ( l_record_t );
            end loop;

        end if;

        if p_report_type = 'SFORD_ALL_CLAIMS_REPORT' then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(pay_date, 'mm/dd/yyyy')         pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    check_number,
                    to_number(claim_amount)                 claim_amount,
                    transaction_number,
                    reimbursement_method,
                    reason_code,
                    service_type_meaning,
                    to_char(plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(plan_end_date, 'MM/DD/YYYY') plan_year,
                    service_type                            plan_type,
                    division_name,
                    division_code,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(transaction_date, 'mm/dd/yyyy') claim_date,
                    'Yes'                                   substantiated,
                    provider_name,
                    deductible_amount,
                    claim_status
                from
                    claim_report_online_v
                where
                        entrp_id = p_entrp_id
                    and trunc(pay_date) >= p_start_date
                    and trunc(pay_date) <= p_end_date
                    and product_type = 'HRA'
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
                union all
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(paid_date, 'mm/dd/yyyy')        pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    null,
                    to_number(claim_amount)                 claim_amount,
                    claim_id,
                    'Debit Card',
                    13,
                    service_type_meaning,
                    to_char(plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(plan_end_date, 'MM/DD/YYYY') plan_year,
                    service_type,
                    division_name,
                    division_code,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(claim_date, 'mm/dd/yyyy')       claim_date,
                    decode(
                        nvl(substantiated, 'Y'),
                        'Y',
                        'Yes',
                        'No'
                    ),
                    provider_name,
                    deductible_amount,
                    claim_status
                from
                    hrafsa_debit_card_claims_v
                where
                        entrp_id = p_entrp_id
                    and trunc(claim_date) >= p_start_date
                    and trunc(claim_date) <= p_end_date
                    and product_type = 'HRA'
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.pay_date := x.pay_date;
                l_record_t.approved_amount := x.approved_amount;
                l_record_t.claim_pending := x.claim_pending;
                l_record_t.check_amount := x.check_amount;
                l_record_t.check_number := x.check_number;
                l_record_t.claim_amount := x.claim_amount;
                l_record_t.transaction_number := x.transaction_number;
                l_record_t.reimbursement_method := x.reimbursement_method;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;
                l_record_t.reason_code := x.reason_code;
                l_record_t.service_type := x.plan_type;
                l_record_t.denied_amount := x.denied_amount;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.service_type_meaning := x.service_type_meaning;
                l_record_t.plan_year := x.plan_year;
                if x.substantiated in ( 'N', 'No' ) then
                    l_record_t.remaining_offset_amt := pc_claim.get_remaining_offset(x.transaction_number);
                end if;

                l_record_t.substantiated_flag := x.substantiated;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                l_record_t.provider_name := x.provider_name;
                l_record_t.deductible_amount := x.deductible_amount;
                l_record_t.claim_status := x.claim_status;
                pipe row ( l_record_t );
            end loop;
        end if;

        if p_report_type = 'MANUAL_CLAIMS_REPORT' then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(pay_date, 'mm/dd/yyyy')         pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    check_number,
                    to_number(claim_amount)                 claim_amount,
                    transaction_number,
                    reimbursement_method,
                    reason_code,
                    service_type_meaning,
                    to_char(plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(plan_end_date, 'MM/DD/YYYY') plan_year,
                    service_type                            plan_type,
                    division_name,
                    division_code,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(transaction_date, 'mm/dd/yyyy') claim_date,
                    pers_id
                from
                    claim_report_online_v
                where
                        entrp_id = p_entrp_id
                    and trunc(pay_date) >= p_start_date
                    and trunc(pay_date) <= p_end_date
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.pay_date := x.pay_date;
                l_record_t.approved_amount := x.approved_amount;
                l_record_t.claim_pending := x.claim_pending;
                l_record_t.check_amount := x.check_amount;
                l_record_t.check_number := x.check_number;
                l_record_t.claim_amount := x.claim_amount;
                l_record_t.transaction_number := x.transaction_number;
                l_record_t.reimbursement_method := x.reimbursement_method;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;
                l_record_t.reason_code := x.reason_code;
                l_record_t.service_type := x.plan_type;
                l_record_t.denied_amount := x.denied_amount;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.service_type_meaning := x.service_type_meaning;
                l_record_t.plan_year := x.plan_year;
                l_record_t.substantiated_flag := 'Yes';
                l_record_t.remaining_offset_amt := 0;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                l_record_t.pers_id := x.pers_id;
                pipe row ( l_record_t );
            end loop;
        end if;

        if p_report_type = 'DEBIT_CARD_CLAIMS' then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(paid_date, 'mm/dd/yyyy')  pay_date,
                    claim_amount,
                    approved_amount,
                    claim_pending,
                    deductible_amount,
                    check_amount,
                    claim_id,
                    division_code,
                    division_name,
                    provider_name,
                    service_type,
                    service_type_meaning,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(claim_date, 'mm/dd/yyyy') claim_date,
                      --  decode(NVL(SUBSTANTIATED,'Y'),'Y','Yes','No') SUBSTANTIATED
                    decode(
                        nvl(substantiated, 'Y'),
                        'Y',
                        'No',
                        'Yes'
                    )                                 substantiated, --(From view it comes as
                                                                                    --Unsubstatiated.Hence while decoding the meaning gets reversed)
                    amount_remaining_for_offset
                from
                    hrafsa_debit_card_claims_v
                where
                        entrp_id = p_entrp_id
                    and trunc(plan_start_date) >= p_plan_start_date
                    and trunc(plan_end_date) <= p_plan_end_date
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.pay_date := x.pay_date;
                l_record_t.claim_amount := x.claim_amount;
                l_record_t.deductible_amount := x.deductible_amount;
                l_record_t.denied_amount := x.denied_amount;
                l_record_t.approved_amount := x.approved_amount;
                l_record_t.claim_pending := x.claim_pending;
                l_record_t.check_amount := x.check_amount;
                l_record_t.transaction_number := x.claim_id;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;
                l_record_t.provider_name := x.provider_name;
                l_record_t.service_type := x.service_type;
                l_record_t.service_type_meaning := x.service_type_meaning;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.claim_date := x.claim_date;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                /* IF X.SUBSTANTIATED IN ('N','No') THEN
                    l_record_t.remaining_offset_amt        := pc_claim.get_remaining_offset(X.CLAIM_ID);
                 END IF;*/
                l_record_t.remaining_offset_amt := x.amount_remaining_for_offset;
                l_record_t.substantiated_flag := x.substantiated;
                pipe row ( l_record_t );
            end loop;
        end if;

  -- Added by Joshi for 12312
        if p_report_type = 'DEBIT_CARD_SWIPE_REPORT' then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(paid_date, 'mm/dd/yyyy')  pay_date,
                    claim_amount,
                    approved_amount,
                    claim_pending,
                    deductible_amount,
                    check_amount,
                    claim_id,
                    division_code,
                    division_name,
                    provider_name,
                    service_type,
                    service_type_meaning,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(claim_date, 'mm/dd/yyyy') claim_date,
                    decode(
                        nvl(substantiated, 'Y'),
                        'Y',
                        'No',
                        'Yes'
                    )                                 substantiated, --(From view it comes as unsubstatiated.Hence while decoding the meaning gets reversed)
                    amount_remaining_for_offset
                from
                    hrafsa_debit_card_claims_v
                where
                        entrp_id = p_entrp_id
                    and reason_code in ( 13, 121 ) -- Added by Joshi for ticket 11232 
                    and trunc(claim_date) >= p_start_date
                    and trunc(claim_date) <= p_end_date
                    and ( division_code is null
                          or division_code = case
                                                 when p_division_code = 'ALL_DIVISION' then
                                                     division_code
                                                 else
                                                     p_division_code
                                             end )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.pay_date := x.pay_date;
                l_record_t.claim_amount := x.claim_amount;
                l_record_t.deductible_amount := x.deductible_amount;
                l_record_t.denied_amount := x.denied_amount;
                l_record_t.approved_amount := x.approved_amount;
                l_record_t.claim_pending := x.claim_pending;
                l_record_t.check_amount := x.check_amount;
                l_record_t.transaction_number := x.claim_id;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;
                l_record_t.provider_name := x.provider_name;
                l_record_t.service_type := x.service_type;
                l_record_t.service_type_meaning := x.service_type_meaning;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.claim_date := x.claim_date;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                /* IF X.SUBSTANTIATED IN ('N','No') THEN
                    l_record_t.remaining_offset_amt        := pc_claim.get_remaining_offset(X.CLAIM_ID);
                 END IF;*/
                l_record_t.remaining_offset_amt := x.amount_remaining_for_offset;
                l_record_t.substantiated_flag := x.substantiated;
                pipe row ( l_record_t );
            end loop;
        end if;

    end get_claims;

    function get_member (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return member_t
        pipelined
        deterministic
    is

        l_record_t  member_row;
        l_acc_id    number(7) := null;       ---- 8669 rprabu 23/01/2020
        l_plan_code number(7) := null;       ---- 8669 rprabu 23/01/2020
    begin
        if
            p_plan_start_date is null
            and p_plan_end_date is null
            and p_plan_type is null
        then
            for x in (
                select
                    replace(a.ssn, '-')                    ssn,
                    a.first_name,
                    a.middle_name,
                    a.last_name,
                    strip_bad(a.phone_day)                 day_phone,
                    a.address,
                    a.city,
                    a.state,
                    a.zip,
                    a.email,
                    to_char(a.birth_date, 'MM/DD/YYYY')    birth_date,
                    pc_person.get_division_name(a.pers_id) division_name,
                    b.acc_num
                from
                    person  a,
                    account b
                where
                        a.entrp_id = p_entrp_id
                    and a.pers_id = b.pers_id
                    and exists (
                        select
                            *
                        from
                            ben_plan_enrollment_setup c
                        where
                                b.acc_id = c.acc_id
                            and c.status = 'A'
                    )
                order by
                    last_name
            ) loop
                l_record_t.ssn := x.ssn;
                l_record_t.first_name := x.first_name;
                l_record_t.middle_name := x.middle_name;
                l_record_t.last_name := x.last_name;
                l_record_t.day_phone := x.day_phone;
                l_record_t.address := x.address;
                l_record_t.city := x.city;
                l_record_t.state := x.state;
                l_record_t.zip := x.zip;
                l_record_t.email := x.email;
                l_record_t.birth_date := x.birth_date;
                l_record_t.acc_num := x.acc_num;
                pipe row ( l_record_t );
            end loop;

        else
            for x in (
                select
                    a.ssn                                                                         ssn    ----REPLACE(A.SSN,'-') SSN  ---- 8669 rprabu 23/01/2020
                    ,
                    a.gender    ---- 8669 rprabu 23/01/2020
                    ,
                    a.first_name,
                    a.middle_name,
                    a.last_name,
                    strip_bad(a.phone_day)                                                        day_phone,
                    a.address,
                    a.city,
                    a.state,
                    a.zip,
                    a.email,
                    to_char(a.birth_date, 'MM/DD/YYYY')                                           birth_date,
                    to_char(c.effective_date, 'MM/DD/YYYY')                                       effective_date,
                    c.annual_election,
                    pc_person.get_division_name(a.pers_id)                                        division_name,
                    pc_benefit_plans.get_deductible(c.ben_plan_id_main, b.acc_id)                 deductible,
                    pc_benefit_plans.get_cov_tier_name(c.ben_plan_id_main, b.acc_id)              cov_tier_name,
                    to_char(c.effective_end_date, 'MM/DD/YYYY')                                   effective_end_date,
                    c.plan_start_date,
                    c.plan_end_date,
                    b.acc_num,
                    c.ben_plan_id         ---- 8669 rprabu 23/01/2020
                    ,
                    c.acc_id              ---- 8669 rprabu 23/01/2020
                    ,
                    nvl(d.funding_type, c.funding_type)                                           funding_type   ---- 8669 rprabu 23/01/2020
                    ,
                    decode(d.claim_reimbursed_by, 'EMPLOYER', 'CLAIM_INVOICE', 'FUNDING_INVOICE') invoice_type   ---- 8669 rprabu 23/01/2020
                from
                    person                    a,
                    account                   b,
                    ben_plan_enrollment_setup c,
                    ben_plan_enrollment_setup d   --- 8669
                where
                        a.entrp_id = p_entrp_id
                    and c.ben_plan_id_main = d.ben_plan_id  --- 8669
                    and a.pers_id = b.pers_id
                    and b.acc_id = c.acc_id
                    and c.plan_type = nvl(p_plan_type, c.plan_type)
                    and c.status = 'A'
                    and d.status = 'A'          --- 8669
                    and c.plan_end_date >= nvl(p_plan_end_date, c.plan_end_date)
                    and c.plan_start_date <= nvl(p_plan_start_date, c.plan_start_date)
                order by
                    last_name
            ) loop
                l_record_t.ssn := x.ssn;
                l_record_t.first_name := x.first_name;
                l_record_t.middle_name := x.middle_name;
                l_record_t.last_name := x.last_name;
                l_record_t.day_phone := x.day_phone;
                l_record_t.address := x.address;
                l_record_t.city := x.city;
                l_record_t.state := x.state;
                l_record_t.zip := x.zip;
                l_record_t.email := x.email;
                l_record_t.birth_date := x.birth_date;
                l_record_t.effective_date := x.effective_date;
                l_record_t.annual_election := x.annual_election;
                l_record_t.division_name := x.division_name;
                l_record_t.deductible := x.deductible;
                l_record_t.cov_tier_name := x.cov_tier_name;
                l_record_t.effective_end_date := x.effective_end_date;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.acc_num := x.acc_num;
                l_record_t.funding_type := x.funding_type;       ---- 8669 Start rprabu 23/01/2020
                l_record_t.gender := x.gender;
                l_record_t.invoice_type := x.invoice_type;
                begin
                    begin
                        select
                            acc_id,
                            plan_code
                        into
                            l_acc_id,
                            l_plan_code
                        from
                            account
                        where
                            entrp_id = p_entrp_id;

                    exception
                        when others then
                            null;
                    end;

                    l_record_t.debit_card := null;
                    l_record_t.payment_start_date := null;
                    l_record_t.recurring_frequency := null;
                    l_record_t.plan_type := null;
                    l_record_t.plan_code := null;
                    l_record_t.ee_amount := 0;
                    l_record_t.er_amount := 0;
                    l_record_t.scheduler_id := null;
                    l_record_t.no_of_pay_periods := 0;
                    select
                        decode(
                            pc_entrp.card_allowed(p_entrp_id),
                            0,
                            'No',
                            ' Yes'
                        )                                           debit_card,
                        to_char(a.payment_start_date, 'mm/dd/yyyy') payment_start_date,
                        a.recurring_frequency,
                        a.plan_type,
                        (
                            select
                                plan_name
                            from
                                plan_codes
                            where
                                plan_code = l_plan_code
                        )                                           plan_code,
                        nvl(b.er_amount, 0)                         er_amount,
                        nvl(b.ee_amount, 0)                         ee_amount,
                        a.scheduler_id
                    into
                        l_record_t.debit_card,
                        l_record_t.payment_start_date,
                        l_record_t.recurring_frequency,
                        l_record_t.plan_type,
                        l_record_t.plan_code,
                        l_record_t.er_amount,
                        l_record_t.ee_amount,
                        l_record_t.scheduler_id
                    from
                        scheduler_master  a,
                        scheduler_details b
                    where
                            a.acc_id = l_acc_id
                        and b.acc_id (+) = x.acc_id
                        and a.scheduler_id = b.scheduler_id (+)
                        and ( payment_end_date <= p_plan_end_date
                              or p_plan_type in ( 'TRN', 'PKG' ) )
                        and ( payment_start_date >= p_plan_start_date
                              or p_plan_type in ( 'TRN', 'PKG' ) )
                        and a.plan_type = nvl(p_plan_type, plan_type)
                        and b.status = 'A'
                        and rownum < 2
                    order by
                        a.scheduler_id desc;

                    if l_record_t.scheduler_id is not null then
                        begin
                            select
                                count(*)
                            into l_record_t.no_of_pay_periods
                            from
                                scheduler_calendar
                            where
                                    schedule_id = l_record_t.scheduler_id
                                and trunc(period_date) between trunc(to_date(l_record_t.effective_date, 'mm/dd/yyyy')) and trunc(p_plan_end_date
                                );

                        end;
                    end if;

                exception
                    when others then
                        null;
                end;
             ---- 8669 End  rprabu 23/01/2020
                pipe row ( l_record_t );
            end loop;
        end if;
    end get_member;

    function get_dependent (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return dependent_t
        pipelined
        deterministic
    is
        l_record_t dependent_row;
    begin
        pc_log.log_error('get_dependent', 'p_plan_start_date ' || p_plan_start_date);
        pc_log.log_error('get_dependent', 'p_plan_end_date ' || p_plan_end_date);
        pc_log.log_error('get_dependent', 'p_plan_type ' || p_plan_type);
        pc_log.log_error('get_dependent', 'p_entrp_id ' || p_entrp_id);
        for x in (
            select distinct
                replace(a.ssn, '-')                     ssn,
                replace(d.ssn, '-')                     subscriber_ssn,
                a.first_name,
                a.middle_name,
                a.last_name,
                strip_bad(a.phone_day)                  day_phone,
                a.address,
                a.city,
                a.state,
                a.zip,
                to_char(a.birth_date, 'MM/DD/YYYY')     birth_date  -- Replaced MMDDYYYY with MM/DD/YYYY by Swamy on 12/03/2021 for Ticket#9806
                ,
                pc_lookups.get_relat_code(a.relat_code) relation
            from
                person  a,
                person  d,
                account b
                     --   ,   BEN_PLAN_ENROLLMENT_SETUP c
            where
                    a.pers_main = d.pers_id
                and d.entrp_id = p_entrp_id
                and d.pers_id = b.pers_id
                      --AND    B.ACC_ID = C.ACC_ID
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            c.acc_id = b.acc_id
                        and c.status in ( 'P', 'A' )
                )
                --      AND    c.status = 'A'
                --      AND    C.PLAN_START_DATE <= p_plan_start_date
                --      AND    C.PLAN_END_DATE  >= p_plan_end_date
               --       AND    C.PLAN_TYPE = p_plan_type
                and a.pers_end_date is null
        ) loop
            l_record_t.ssn := x.ssn;
            l_record_t.subscriber_ssn := x.subscriber_ssn;
            l_record_t.first_name := x.first_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.last_name := x.last_name;
            l_record_t.day_phone := x.day_phone;
            l_record_t.address := x.address;
            l_record_t.city := x.city;
            l_record_t.state := x.state;
            l_record_t.zip := x.zip;
            l_record_t.birth_date := x.birth_date;
            l_record_t.relation := x.relation;
            pipe row ( l_record_t );
        end loop;

    end get_dependent;

    function get_member_detail (
        p_acc_num in varchar2
    ) return member_t
        pipelined
        deterministic
    is
        l_record_t member_row;
    begin
        for x in (
            select
                replace(a.ssn, '-')                 ssn,
                a.first_name,
                a.middle_name,
                a.last_name,
                strip_bad(a.phone_day)              day_phone,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.email,
                to_char(a.birth_date, 'MMDDYYYY')   birth_date,
                a.first_name
                || ' '
                || a.last_name                      full_name,
                pc_entrp.get_entrp_name(a.entrp_id) er_name
            from
                person  a,
                account b
            where
                    b.acc_num = p_acc_num
                and a.pers_id = b.pers_id
            order by
                last_name
        ) loop
            l_record_t.ssn := x.ssn;
            l_record_t.first_name := x.first_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.last_name := x.last_name;
            l_record_t.day_phone := x.day_phone;
            l_record_t.address := x.address;
            l_record_t.city := x.city;
            l_record_t.state := x.state;
            l_record_t.zip := x.zip;
            l_record_t.email := x.email;
            l_record_t.birth_date := x.birth_date;
            l_record_t.full_name := x.full_name;
            l_record_t.employer_name := x.er_name;
            pipe row ( l_record_t );
        end loop;
    end get_member_detail;

    function get_er_online_accounts (
        p_entrp_id in number
    ) return ret_er_online_accounts_t
        pipelined
        deterministic
    is
        l_record er_online_accounts_t;
    begin
        for x in (
            select
                a.entrp_id,
                a.first_name,
                a.last_name,
                b.acc_num
            from
                person       a,
                account      b,
                online_users c
            where
                    a.pers_id = b.pers_id
                and replace(a.ssn, '-') = c.tax_id
                and c.user_status = 'A'
                and a.entrp_id = p_entrp_id
                and b.account_status in ( 1, 2, 3 )
        ) loop
            l_record.entrp_id := x.entrp_id;
            l_record.first_name := x.first_name;
            l_record.last_name := x.last_name;
            l_record.acc_num := x.acc_num;
            pipe row ( l_record );
        end loop;
    end get_er_online_accounts;

    function get_plan_detail (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_report_type     in varchar2 default 'ENROLLEE_BALANCE'
    ) return plan_detail_t
        pipelined
        deterministic
    is
        l_record_t plan_detail_row;
    begin
        pc_log.log_error('get_plan_detail', 'acc_num' || p_acc_num);
        pc_log.log_error('get_plan_detail', 'p_plan_start_date' || p_plan_start_date);
        pc_log.log_error('get_plan_detail', 'p_plan_end_date' || p_plan_end_date);
        if p_report_type = 'SFORD_ENROLLEE_BALANCE' then
            for x in (
                select
                    to_char(plan_start_date, 'MM/DD/YYYY') plan_start_date,
                    (
                        select
                            sum(nvl(remaining_balance, 0))
                        from
                            table ( pc_reports_pkg.get_hra_sfhso_contribution(x.acc_num) )
                    )                                      acc_balance,
                    nvl(
                        pc_fin.contribution_ytd(acc_id, account_type, plan_type, p_plan_start_date, p_plan_end_date),
                        0.00
                    )                                      deposit,
                    nvl(
                        pc_fin.disbursement_ytd(acc_id, account_type, plan_type, null, p_plan_start_date,
                                                p_plan_end_date),
                        0.00
                    )                                      claims
                from
                    fsa_hra_employees_v x
                where
                        acc_num = p_acc_num
            --     AND   TERMINATION_DATE  IS NULL
                    and product_type = 'HRA'
            ) loop
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.contribution_ytd := x.deposit;
                l_record_t.disbursement_ytd := x.claims;
                l_record_t.available_balance := x.acc_balance;
                pipe row ( l_record_t );
            end loop;
        elsif p_report_type = 'ONLINE_ENROLLMENT_APP' then
            for x in (
                select
                    a.plan_type_meaning,
                    a.plan_type,
                    a.plan_start_date,
                    a.plan_end_date,
                    a.annual_election,
                    a.acc_id,
                    a.account_type,
                    a.ben_plan_id,
                    a.effective_date
                from
                    enroll_qtr_ee_plan_v a,
                    online_enrollment    b,
                    online_enroll_plans  c
                where
                            a.acc_num = p_acc_num
                        and a.acc_num = b.acc_num
                        and b.creation_date > sysdate - 1
                                                        and c.enrollment_id = b.enrollment_id
                    and c.ben_plan_id = a.ben_plan_id
                    and a.plan_end_date + a.runout_period_days + a.grace_period >= sysdate
            ) loop
                pc_log.log_error('get_plan_detail', 'got data' || x.plan_type);
                l_record_t.plan_type_meaning := x.plan_type_meaning;
                l_record_t.plan_type := x.plan_type;
                l_record_t.plan_start_date := to_char(x.plan_start_date, 'MM/DD/YYYY');
                l_record_t.plan_end_date := to_char(x.plan_end_date, 'MM/DD/YYYY');
                l_record_t.effective_date := x.effective_date;
                l_record_t.annual_election := x.annual_election;
                l_record_t.contribution_ytd := pc_fin.contribution_ytd(x.acc_id, x.account_type, x.plan_type, p_plan_start_date, p_plan_end_date
                );

                l_record_t.disbursement_ytd := pc_fin.disbursement_ytd(x.acc_id, x.account_type, x.plan_type, null, p_plan_start_date
                ,
                                                                       p_plan_end_date);

                l_record_t.available_balance := get_quarter_balance(x.acc_id, x.plan_type, x.plan_start_date, x.plan_end_date, x.ben_plan_id
                );

                pipe row ( l_record_t );
            end loop;
        else
            for x in (
                select
                    plan_type_meaning,
                    plan_type,
                    plan_start_date,
                    plan_end_date,
                    annual_election,
                    acc_id,
                    account_type,
                    ben_plan_id,
                    effective_date
                from
                    enroll_qtr_ee_plan_v
                where
                        acc_num = p_acc_num
                    and ( plan_start_date <= p_plan_start_date
                          and plan_end_date + runout_period_days + grace_period >= p_plan_end_date )
            ) loop
                pc_log.log_error('get_plan_detail', 'got data' || x.plan_type);
                l_record_t.plan_type_meaning := x.plan_type_meaning;
                l_record_t.plan_type := x.plan_type;
                l_record_t.plan_start_date := to_char(x.plan_start_date, 'MM/DD/YYYY');
                l_record_t.plan_end_date := to_char(x.plan_end_date, 'MM/DD/YYYY');
                l_record_t.annual_election := x.annual_election;
                l_record_t.effective_date := to_char(x.effective_date, 'MM/DD/YYYY');
                l_record_t.contribution_ytd := pc_fin.contribution_ytd(x.acc_id, x.account_type, x.plan_type, p_plan_start_date, p_plan_end_date
                );

                l_record_t.disbursement_ytd := pc_fin.disbursement_ytd(x.acc_id, x.account_type, x.plan_type, null, p_plan_start_date
                ,
                                                                       p_plan_end_date);

                l_record_t.available_balance := get_quarter_balance(x.acc_id, x.plan_type, x.plan_start_date, x.plan_end_date, x.ben_plan_id
                );

                pipe row ( l_record_t );
            end loop;
        end if;

    end get_plan_detail;

    function get_member_claims (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2,
        p_report_type     in varchar2
    ) return claim_t
        pipelined
        deterministic
    is
        l_record_t claim_row;
    begin
        pc_log.log_error('get_member_claims', 'p_start_date ' || p_start_date);
        pc_log.log_error('get_member_claims', 'p_end_date ' || p_end_date);
        pc_log.log_error('get_member_claims', 'p_report_type ' || p_report_type);
        if p_report_type = 'SFORD_ALL_CLAIMS_REPORT' then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(pay_date, 'mm/dd/yyyy')         pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    check_number,
                    to_number(claim_amount)                 claim_amount,
                    transaction_number,
                    reimbursement_method,
                    reason_code,
                    service_type_meaning,
                    to_char(plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(plan_end_date, 'MM/DD/YYYY') plan_year,
                    service_type                            plan_type,
                    division_name,
                    division_code,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(transaction_date, 'mm/dd/yyyy') claim_date,
                    'Yes'                                   substantiated,
                    provider_name,
                    deductible_amount,
                    claim_status
                from
                    claim_report_online_v
                where
                        acc_num = p_acc_num
                    and trunc(pay_date) >= p_start_date
                    and trunc(pay_date) <= p_end_date
                    and product_type = 'HRA'
                union all
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(paid_date, 'mm/dd/yyyy')        pay_date,
                    approved_amount,
                    claim_pending,
                    check_amount,
                    null,
                    to_number(claim_amount)                 claim_amount,
                    claim_id,
                    'Debit Card',
                    13,
                    service_type_meaning,
                    to_char(plan_start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(plan_end_date, 'MM/DD/YYYY') plan_year,
                    service_type,
                    division_name,
                    division_code,
                    denied_amount,
                    plan_start_date,
                    plan_end_date,
                    to_char(claim_date, 'mm/dd/yyyy')       claim_date,
                    decode(
                        nvl(substantiated, 'Y'),
                        'Y',
                        'Yes',
                        'No'
                    ),
                    provider_name,
                    deductible_amount,
                    claim_status
                from
                    hrafsa_debit_card_claims_v
                where
                        acc_num = p_acc_num
                    and trunc(claim_date) >= p_start_date
                    and trunc(claim_date) <= p_end_date
                    and product_type = 'HRA'
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.pay_date := x.pay_date;
                l_record_t.approved_amount := x.approved_amount;
                l_record_t.claim_pending := x.claim_pending;
                l_record_t.check_amount := x.check_amount;
                l_record_t.check_number := x.check_number;
                l_record_t.claim_amount := x.claim_amount;
                l_record_t.transaction_number := x.transaction_number;
                l_record_t.reimbursement_method := x.reimbursement_method;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;
                l_record_t.reason_code := x.reason_code;
                l_record_t.service_type := x.plan_type;
                l_record_t.denied_amount := x.denied_amount;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.plan_end_date := x.plan_end_date;
                l_record_t.service_type_meaning := x.service_type_meaning;
                l_record_t.plan_year := x.plan_year;
                if x.substantiated = 'N' then
                    l_record_t.remaining_offset_amt := pc_claim.get_remaining_offset(x.transaction_number);
                end if;

                l_record_t.substantiated_flag := x.substantiated;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                l_record_t.provider_name := x.provider_name;
                l_record_t.deductible_amount := x.deductible_amount;
                l_record_t.claim_status := x.claim_status;
                pipe row ( l_record_t );
            end loop;
        end if;

    end get_member_claims;

    function get_contribution (
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_plan_type     in varchar2,
        p_division_code in varchar2,
        p_report_type   in varchar2
    ) return deposit_t
        pipelined
        deterministic
    is
        l_record_t      deposit_row;
        l_division_code varchar2(30);
    begin
        l_division_code := p_division_code;
        pc_log.log_error('get_contribution', 'p_end_date ' || p_end_date);
        pc_log.log_error('get_contribution', 'p_start_date ' || p_start_date);
        pc_log.log_error('get_contribution', 'p_entrp_id ' || p_entrp_id);
        pc_log.log_error('get_contribution', 'p_plan_type ' || p_plan_type);
        pc_log.log_error('get_contribution', 'DIVISION CODE ' || p_division_code);
        dbms_output.put_line('get_contribution'
                             || 'DIVISION CODE '
                             || p_division_code);
        if l_division_code = 'ALL_DIVISION' then
            l_division_code := null;
        end if;
        if p_report_type = 'SUMMARY' then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    sum(er_amount)                             er_contrib,
                    sum(ee_amount)                             ee_contrib,
                    sum(nvl(ee_amount, 0) + nvl(er_amount, 0)) total_amount,
                    plan_type,
                    division_name
                from
                    ee_deposits_v
                where
                        fee_date >= p_start_date
                    and fee_date <= p_end_date
                    and entrp_id = p_entrp_id
                    and plan_type = p_plan_type
                    and ( division_code is null
                          or division_code = nvl(l_division_code, division_code) )
                group by
                    acc_num,
                    first_name,
                    last_name,
                    plan_type,
                    division_name
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.ee_contribution := x.ee_contrib;
                l_record_t.er_contribution := x.er_contrib;
                l_record_t.total_amount := x.total_amount;
                l_record_t.division_name := x.division_name;
                pipe row ( l_record_t );
            end loop;
        else
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    er_amount                             er_contrib,
                    ee_amount                             ee_contrib,
                    nvl(ee_amount, 0) + nvl(er_amount, 0) total_amount,
                    plan_type,
                    division_name,
                    to_char(fee_date, 'MM/DD/YYYY')       fee_date
                from
                    ee_deposits_v
                where
                        fee_date >= p_start_date
                    and fee_date <= p_end_date
                    and entrp_id = p_entrp_id
                    and plan_type = p_plan_type
                    and ( division_code is null
                          or division_code = nvl(l_division_code, division_code) )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.ee_contribution := x.ee_contrib;
                l_record_t.er_contribution := x.er_contrib;
                l_record_t.total_amount := x.total_amount;
                l_record_t.division_name := x.division_name;
                l_record_t.fee_date := x.fee_date;
                pipe row ( l_record_t );
            end loop;
        end if;

    end get_contribution;

    function get_enrollee_balance (
        p_entrp_id        in number,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return enrollee_balance_t
        pipelined
        deterministic
    is
        l_record_t      enrollee_balance_row;
        l_division_code varchar2(30);
    begin
        l_division_code := p_division_code;
        if l_division_code = 'ALL_DIVISION' then
            l_division_code := null;
        end if;
        pc_log.log_error('get_enrollee_balance', 'p_entrp_id ' || p_entrp_id);
        pc_log.log_error('get_enrollee_balance', 'p_start_date ' || p_start_date);
        pc_log.log_error('get_enrollee_balance', 'p_end_date ' || p_end_date);
        pc_log.log_error('get_enrollee_balance', 'p_plan_start_date ' || p_plan_start_date);
        pc_log.log_error('get_enrollee_balance', 'p_plan_end_date ' || p_plan_end_date);
        pc_log.log_error('get_enrollee_balance', 'p_plan_type ' || p_plan_type);
        pc_log.log_error('get_enrollee_balance', 'p_division_code ' || p_division_code);
        if p_entrp_id in ( 29742, 9105 ) then
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(end_date, 'MM/DD/YYYY')   termination_date,
                    to_char(start_date, 'MM/DD/YYYY') as plan_start_date,
                    start_date,
                    annual_election,
                    acc_id,
                    account_type,
                    end_date,
                    plan_type_meaning,
                    plan_type,
                    division_code,
                    division_name  --   Annual_Election_Wo_Rollover  And Rollover Added By Rprabu For Ticket#5824 on 18/07/2018
		--- , Annual_Election - Pc_Benefit_Plans.Get_Rollover(Acc_Id,Plan_Type,Plan_Start_Date,Plan_End_Date)  Annual_Election_Wo_Rollover -- commented by rprabu for performance issue as per vanitha advice.
        --  , Pc_Benefit_Plans.Get_Rollover(Acc_Id,Plan_Type,Plan_Start_Date,Plan_End_Date) Rollover -- commented by rprabu for performance issue as per vanitha advice. 10/07/2020
           /*Ticket#6323 */,
                    runout_period_days,
                    grace_period
                from
                    fsa_hra_employees_queens_v
                where
                        entrp_id = p_entrp_id
                    and status not in ( 'P', 'R' )
                    and plan_type = nvl(p_plan_type, plan_type)
                    and plan_start_date = p_plan_start_date
                    and plan_end_date = p_plan_end_date
           --AND (DIVISION_CODE IS NULL OR DIVISION_CODE = NVL(p_division_code,DIVISION_CODE))
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.name := x.first_name
                                   || ' '
                                   || x.last_name;
                l_record_t.termination_date := x.termination_date;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.annual_election := x.annual_election;
                if x.end_date is not null then
                    l_record_t.acc_balance := pc_account.previous_acc_balance(x.acc_id, x.start_date, x.end_date, x.account_type, x.plan_type
                    ,
                                                                              p_plan_start_date, p_plan_end_date);

                   --  L_Record_T.Deposit	    := Pc_Fin.Contribution_Ytd(X.Acc_Id, X.Account_Type,X.Plan_Type
                     -- 				, X.Start_Date, X.End_Date);
                   --As per ticket#6308 , while calculating Contributions we just need to consider plan end date. Termination date is not important.
             --   l_record_t.deposit      := PC_FIN.CONTRIBUTION_YTD(X.ACC_ID, X.ACCOUNT_TYPE,X.PLAN_TYPE , x.start_date, p_end_date);
             --   L_Record_T.Disbursement := Pc_Fin.Disbursement_Ytd(X.Acc_Id, X.Account_Type,X.Plan_Type,Null
							--				, X.Start_Date, X.End_Date);

              --As per ticket#6308 , while calculating Contributions/claims we just need to consider plan end date. Termination date is not important.
        /*Ticket#6323.For contributions end date shud be lest of plan end date and termination date. For claims we consider grace period */

                    l_record_t.deposit := pc_fin.contribution_ytd(x.acc_id,
                                                                  x.account_type,
                                                                  x.plan_type,
                                                                  x.start_date,
                                                                  least(x.end_date, p_end_date));
                 /* L_Record_T.Disbursement := Pc_Fin.Disbursement_Ytd(X.Acc_Id, X.Account_Type,X.Plan_Type,Null
											, X.Start_Date, (X.End_Date+X.runout_period_days+X.grace_period)); */
			--	L_Record_T.Disbursement := Pc_Fin.Disbursement_Ytd(X.Acc_Id, X.Account_Type,X.Plan_Type,Null
			--								, X.Start_Date, (X.End_Date+ NVL(X.runout_period_days,0) + NVL(X.grace_period, 0) )); -- Added NVL Joshi
            -- Vanitha: fixed on 3/30/2020 to fix sugar case 77185
                    l_record_t.disbursement := pc_fin.disbursement_ytd(x.acc_id, x.account_type, x.plan_type, null, x.start_date,
                                                                       p_end_date); -- Added NVL Joshi

                else
                    l_record_t.acc_balance := pc_account.current_hrafsa_balance(x.acc_id, x.start_date, p_end_date, p_plan_start_date
                    , p_plan_end_date,
                                                                                x.plan_type);

                    l_record_t.deposit := pc_fin.contribution_ytd(x.acc_id, x.account_type, x.plan_type, x.start_date, p_end_date);

                    l_record_t.disbursement := pc_fin.disbursement_ytd(x.acc_id, x.account_type, x.plan_type, null, x.start_date,
                                                                       p_end_date);

                end if;

                l_record_t.plan_type_meaning := x.plan_type_meaning;
                l_record_t.plan_type := x.plan_type;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;

		   -- commented by rprabu and rewritten as below for performance issue as per vanitha advice. 10/07/2020
		   --  L_Record_T.Rollover      := X.Rollover;                                  -- Added By Swamy For Ticket#5824
		   --  L_Record_T.Annual_Election_Wo_Rollover := X.Annual_Election_Wo_Rollover; -- Added By Swamy For Ticket#5824
                l_record_t.rollover := pc_benefit_plans.get_rollover(x.acc_id, x.plan_type, p_plan_start_date, p_plan_end_date);

                l_record_t.annual_election_wo_rollover := x.annual_election - l_record_t.rollover;
                pipe row ( l_record_t );
            end loop;
        else
            for x in (
                select
                    acc_num,
                    first_name,
                    last_name,
                    to_char(end_date, 'MM/DD/YYYY')   termination_date,
                    to_char(start_date, 'MM/DD/YYYY') as plan_start_date,
                    annual_election,
                    acc_id,
                    account_type,
                    end_date,
                    plan_type_meaning,
                    plan_type,
                    division_code,
                    division_name  --Annual_Election_Wo_Rollover  And Rollover Added By Rprabu For Ticket#5824
	 	     -- ,  Annual_Election Annual_Election_Wo_Rollover
         -- , Annual_Election Rollover
  	     --  , Annual_Election - Pc_Benefit_Plans.Get_Rollover(Acc_Id,Plan_Type,Plan_Start_Date,Plan_End_Date)  Annual_Election_Wo_Rollover
         -- , Pc_Benefit_Plans.Get_Rollover(Acc_Id,Plan_Type,Plan_Start_Date,Plan_End_Date) Rollover
                from
                    fsa_hra_employees_v
                where
                        entrp_id = p_entrp_id
                    and status <> 'R'
                    and plan_type = nvl(p_plan_type, plan_type)
                    and plan_start_date = p_plan_start_date
                    and plan_end_date = p_plan_end_date
                    and ( division_code is null
                          or division_code = nvl(l_division_code, division_code) )
            ) loop
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.termination_date := x.termination_date;
                l_record_t.plan_start_date := x.plan_start_date;
                l_record_t.annual_election := x.annual_election;
                l_record_t.acc_balance := pc_account.current_hrafsa_balance(x.acc_id, p_start_date, p_end_date, p_plan_start_date, p_plan_end_date
                ,
                                                                            x.plan_type);

                l_record_t.deposit := pc_fin.contribution_ytd(x.acc_id, x.account_type, x.plan_type, p_start_date, p_end_date);

                l_record_t.disbursement := pc_fin.disbursement_ytd(x.acc_id, x.account_type, x.plan_type, null, p_start_date,
                                                                   p_end_date);

                l_record_t.claims_paid_ytd := pc_fin.claim_filed_ytd(x.acc_id, x.account_type, x.plan_type, p_start_date, p_end_date)
                ;

                l_record_t.plan_type_meaning := x.plan_type_meaning;
                l_record_t.plan_type := x.plan_type;
                l_record_t.division_code := x.division_code;
                l_record_t.division_name := x.division_name;

           -- commented by rprabu and rewritten as below for performance issue as per vanitha advice. 10/07/2020
			-- L_Record_T.Rollover                      := X.Rollover;                     -- Added By Rprabu For Ticket#5824
		   --- L_Record_T.Annual_Election_Wo_Rollover   := X.Annual_Election_Wo_Rollover;  -- Added By Rprabu For Ticket#5824
                l_record_t.rollover := pc_benefit_plans.get_rollover(x.acc_id, x.plan_type, p_plan_start_date, p_plan_end_date);

                l_record_t.annual_election_wo_rollover := x.annual_election - l_record_t.rollover;
                pipe row ( l_record_t );
            end loop;
        end if;

    exception
        when others then
            raise;
    end get_enrollee_balance;

    function get_sford_plan_detail (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_report_type     in varchar2 default 'ENROLLEE_BALANCE'
    ) return plan_detail_t
        pipelined
        deterministic
    is
        l_record_t    plan_detail_row;
        l_rolled_over varchar2(1);
    begin
        pc_log.log_error('get_plan_detail', 'acc_num' || p_acc_num);
        pc_log.log_error('get_plan_detail', 'p_plan_start_date' || p_plan_start_date);
        pc_log.log_error('get_plan_detail', 'p_plan_end_date' || p_plan_end_date);
        if p_report_type = 'SFORD_ENROLLEE_BALANCE' then
            for x in (
                select
                    acc_id,
                    to_char(plan_start_date, 'MM/DD/YYYY') plan_start_date,
                    plan_end_date,
                    (
                        select
                            sum(nvl(remaining_balance, 0))
                        from
                            table ( pc_reports_pkg.get_hra_sfhso_contribution(x.acc_num) )
                    )                                      acc_balance,
                    nvl(
                        pc_fin.contribution_ytd(acc_id, account_type, plan_type, p_plan_start_date, p_plan_end_date),
                        0.00
                    )                                      deposit,
                    nvl(
                        pc_fin.disbursement_ytd(acc_id, account_type, plan_type, null, p_plan_start_date,
                                                p_plan_end_date),
                        0.00
                    )                                      claims
                from
                    fsa_hra_employees_v x
                where
                        acc_num = p_acc_num
                    and sf_ordinance_flag = 'Y'
                    and product_type = 'HRA'
                order by
                    plan_end_date asc
            ) loop
                if l_rolled_over is null then
                    l_rolled_over := pc_fin.is_rolled_over(x.acc_id, x.plan_end_date);
                end if;

                if l_rolled_over = 'Y' then
                    if x.plan_end_date > sysdate then
                        l_record_t.plan_start_date := x.plan_start_date;
                        l_record_t.contribution_ytd := x.deposit;
                        l_record_t.disbursement_ytd := x.claims;
                        l_record_t.available_balance := x.acc_balance;
                        pipe row ( l_record_t );
                    end if;

                else
                    l_record_t.plan_start_date := x.plan_start_date;
                    l_record_t.contribution_ytd := x.deposit;
                    l_record_t.disbursement_ytd := x.claims;
                    l_record_t.available_balance := x.acc_balance;
                    pipe row ( l_record_t );
                end if;

            end loop;
        end if;

    end get_sford_plan_detail;

    function get_pending_member (
        p_entrp_id  in number,
        p_plan_type in varchar2
    ) return member_t
        pipelined
        deterministic
    is
        l_record_t member_row;
    begin
        for x in (
            select
                replace(a.ssn, '-')                                              ssn,
                a.first_name,
                a.middle_name,
                a.last_name,
                strip_bad(a.phone_day)                                           day_phone,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.email,
                to_char(a.birth_date, 'MMDDYYYY')                                birth_date,
                to_char(c.effective_date, 'MMDDYYYY')                            effective_date,
                c.annual_election,
                pc_person.get_division_name(a.pers_id)                           division_name,
                pc_benefit_plans.get_deductible(c.ben_plan_id_main, b.acc_id)    deductible,
                pc_benefit_plans.get_cov_tier_name(c.ben_plan_id_main, b.acc_id) cov_tier_name,
                to_char(c.effective_end_date, 'MM/DD/YYYY')                      effective_end_date,
                c.plan_start_date,
                c.plan_end_date,
                d.pay_cycle,
                d.first_payroll_date                                             first_payroll_date,
                d.pay_contrb
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c,
                pay_details               d
            where
                    a.entrp_id = p_entrp_id
                and c.status = 'P'
                and c.plan_type = p_plan_type
                and a.pers_id = b.pers_id
                and b.acc_id = c.acc_id
                and c.ben_plan_id = d.ben_plan_id (+)
                and d.acc_id (+) = c.acc_id
            order by
                last_name
        ) loop
            l_record_t.ssn := x.ssn;
            l_record_t.first_name := x.first_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.last_name := x.last_name;
            l_record_t.day_phone := x.day_phone;
            l_record_t.address := x.address;
            l_record_t.city := x.city;
            l_record_t.state := x.state;
            l_record_t.zip := x.zip;
            l_record_t.email := x.email;
            l_record_t.birth_date := x.birth_date;
            l_record_t.effective_date := x.effective_date;
            l_record_t.annual_election := x.annual_election;
            l_record_t.division_name := x.division_name;
            l_record_t.deductible := x.deductible;
            l_record_t.cov_tier_name := x.cov_tier_name;
            l_record_t.effective_end_date := x.effective_end_date;
            l_record_t.plan_start_date := to_char(x.plan_start_date, 'MM/DD/YYYY');
            l_record_t.plan_end_date := to_char(x.plan_end_date, 'MM/DD/YYYY');
            l_record_t.pay_cycle := x.pay_cycle;
            l_record_t.first_payroll_date := x.first_payroll_date;
            l_record_t.pay_contribution := x.pay_contrb;
            pipe row ( l_record_t );
        end loop;
    end get_pending_member;

    function get_yearend_summary (
        p_acc_num in varchar2
    ) return plan_yearend_t
        pipelined
        deterministic
    is
        l_record_t plan_yearend_row_t;
    begin
        for x in (
            select
                plan_type_meaning,
                to_char(effective_date, 'MM/DD/YYYY')                             effective_date,
                to_char(effective_end_date, 'MM/DD/YYYY')                         effective_end_date,
                decode(runout_period_term,
                       'CPE',
                       nvl(effective_end_date, plan_end_date),
                       plan_end_date) + nvl(grace_period, 0) + runout_period_days runout_date,
                plan_type,
                decode(runout_period_term,
                       'CPE',
                       nvl(effective_end_date, plan_end_date),
                       plan_end_date) + nvl(grace_period, 0)                      grace_period,
                b.max_rollover_amount
            from
                fsa_hra_ee_ben_plans_v a,
                ben_plan_coverages     b
            where
                    a.plan_end_date + nvl(a.runout_period_days, 0) + nvl(a.grace_period, 0) >= sysdate
                and a.plan_start_date < sysdate
                and a.ben_plan_id = b.ben_plan_id (+)
                and a.acc_num = p_acc_num
                and a.status not in ( 'P', 'R' )
            order by
                plan_type
        ) loop
            l_record_t.plan_type_meaning := x.plan_type_meaning;
            l_record_t.effective_date := x.effective_date;
            l_record_t.effective_end_date := x.effective_end_date;
            l_record_t.runout_date := to_char(x.runout_date, 'MM/DD/YYYY');
            l_record_t.grace_period := to_char(x.grace_period, 'MM/DD/YYYY');
            l_record_t.plan_type := x.plan_type;
            l_record_t.max_rollover_amount := x.max_rollover_amount;
            pipe row ( l_record_t );
        end loop;
    end get_yearend_summary;

    function get_revenue_summary (
        p_account_type in varchar2
    ) return revenue_t
        pipelined
        deterministic
    is
        l_record_t revenue_row_t;
    begin
        if p_account_type = 'HSA' then
            for x in (
                select
                    check_year,
                    check_mon,
                    check_mm,
                    sum(setup_fee)   setup_fee,
                    sum(monthly_fee) monthly_fee,
                    sum(other_fee)   other_fee,
                    account_type
                from
                    (
                        select
                            to_char(pay_date, 'YYYY') check_year,
                            to_char(pay_date, 'MON')  check_mon,
                            to_char(pay_date, 'MM')   check_mm,
                            sum(nvl(amount, 0))       setup_fee,
                            0                         monthly_fee,
                            0                         other_fee,
                            'HSA'                     account_type
                        from
                            payment a,
                            account b
                        where
                                a.acc_id = b.acc_id
                            and b.account_type = 'HSA'
                            and a.reason_code = 1
                        group by
                            to_char(pay_date, 'YYYY'),
                            to_char(pay_date, 'MON'),
                            to_char(pay_date, 'MM')
                        union
                        select
                            to_char(pay_date, 'YYYY') check_year,
                            to_char(pay_date, 'MON')  check_mon,
                            to_char(pay_date, 'MM')   check_mm,
                            0                         setup_fee,
                            sum(nvl(amount, 0))       monthly_fee,
                            0                         other_fee,
                            'HSA'
                        from
                            payment a,
                            account b
                        where
                                a.acc_id = b.acc_id
                            and b.account_type = 'HSA'
                            and a.reason_code = 2
                        group by
                            to_char(pay_date, 'YYYY'),
                            to_char(pay_date, 'MON'),
                            to_char(pay_date, 'MM')
                        union
                        select
                            to_char(pay_date, 'YYYY') check_year,
                            to_char(pay_date, 'MON')  check_mon,
                            to_char(pay_date, 'MM')   check_mm,
                            0                         setup_fee,
                            0                         monthly_fee,
                            sum(nvl(amount, 0))       other_fee,
                            'HSA'
                        from
                            payment    a,
                            account    b,
                            pay_reason c
                        where
                                a.acc_id = b.acc_id
                            and b.account_type = 'HSA'
                            and a.reason_code not in ( 1, 2 )
                            and a.reason_code = c.reason_code
                            and c.reason_type = 'FEE'
                        group by
                            to_char(pay_date, 'YYYY'),
                            to_char(pay_date, 'MON'),
                            to_char(pay_date, 'MM')
                    )
                group by
                    check_year,
                    check_mon,
                    check_mm,
                    account_type
            ) loop
                l_record_t.check_year := x.check_year;
                l_record_t.check_mon := x.check_mon;
                l_record_t.check_mm := x.check_mm;
                l_record_t.setup_fee := x.setup_fee;
                l_record_t.monthly_fee := x.monthly_fee;
                l_record_t.other_fee := x.other_fee;
                l_record_t.renewal_fee := 0;
                pipe row ( l_record_t );
            end loop;
        end if;

        if p_account_type not in ( 'POP', 'HSA' ) then
            for x in (
                select
                    check_year,
                    check_mon,
                    check_mm,
                    sum(setup_fee)   setup_fee,
                    sum(monthly_fee) monthly_fee,
                    sum(other_fee)   other_fee,
                    sum(renewal_fee) renewal_fee,
                    account_type
                from
                    (
                        select
                            to_char(check_date, 'YYYY') check_year,
                            to_char(check_date, 'MON')  check_mon,
                            to_char(check_date, 'MM')   check_mm,
                            sum(nvl(check_amount, 0))   setup_fee,
                            0                           monthly_fee,
                            0                           other_fee,
                            0                           renewal_fee,
                            b.account_type
                        from
                            employer_payments a,
                            account           b
                        where
                                reason_code = 1
                            and b.account_type = p_account_type
                            and a.entrp_id = b.entrp_id
                        group by
                            b.account_type,
                            to_char(check_date, 'YYYY'),
                            to_char(check_date, 'MON'),
                            to_char(check_date, 'MM')
                        union
                        select
                            to_char(check_date, 'YYYY') check_year,
                            to_char(check_date, 'MON')  check_mon,
                            to_char(check_date, 'MM')   check_mm,
                            0,
                            sum(nvl(check_amount, 0))   monthly_fee,
                            0                           other_fee,
                            0                           renewal_fee,
                            b.account_type
                        from
                            employer_payments a,
                            account           b
                        where
                                reason_code = 2
                            and b.account_type = p_account_type
                            and a.entrp_id = b.entrp_id
                        group by
                            b.account_type,
                            to_char(check_date, 'YYYY'),
                            to_char(check_date, 'MON'),
                            to_char(check_date, 'MM')
                        union
                        select
                            to_char(check_date, 'YYYY') check_year,
                            to_char(check_date, 'MON')  check_mon,
                            to_char(check_date, 'MM')   check_mm,
                            0,
                            0,
                            sum(nvl(check_amount, 0))   other_fee,
                            0,
                            b.account_type
                        from
                            employer_payments a,
                            account           b,
                            pay_reason        c
                        where
                            nvl(a.reason_code, -1) not in ( 30, 46, 45, 1, 2 )
                            and c.reason_code = a.reason_code
                            and b.account_type = p_account_type
                            and c.reason_type = 'FEE'
                            and a.entrp_id = b.entrp_id
                        group by
                            b.account_type,
                            to_char(check_date, 'YYYY'),
                            to_char(check_date, 'MON'),
                            to_char(check_date, 'MM')
                        union
                        select
                            to_char(check_date, 'YYYY') check_year,
                            to_char(check_date, 'MON')  check_mon,
                            to_char(check_date, 'MM')   check_mm,
                            0,
                            0,
                            0                           other_fee,
                            sum(nvl(check_amount, 0)),
                            b.account_type
                        from
                            employer_payments a,
                            account           b,
                            pay_reason        c
                        where
                            a.reason_code in ( 30, 46, 45 )
                            and c.reason_code = a.reason_code
                            and b.account_type = p_account_type
             --       AND     C.REASON_TYPE = 'FEE'
                            and a.entrp_id = b.entrp_id
                        group by
                            b.account_type,
                            to_char(check_date, 'YYYY'),
                            to_char(check_date, 'MON'),
                            to_char(check_date, 'MM')
                    )
                group by
                    check_year,
                    check_mon,
                    check_mm,
                    account_type
            ) loop
                l_record_t.check_year := x.check_year;
                l_record_t.check_mon := x.check_mon;
                l_record_t.check_mm := x.check_mm;
                l_record_t.setup_fee := x.setup_fee;
                l_record_t.monthly_fee := x.monthly_fee;
                l_record_t.other_fee := x.other_fee;
                l_record_t.renewal_fee := x.renewal_fee;
                pipe row ( l_record_t );
            end loop;

        end if;

        if p_account_type = 'POP' then
            for x in (
                select
                    to_char(check_date, 'YYYY') check_year,
                    to_char(check_date, 'MON')  check_mon,
                    to_char(check_date, 'MM')   check_mm,
                    sum(nvl(check_amount, 0))   setup_fee,
                    0                           monthly_fee,
                    0                           other_fee,
                    'POP'                       account_type
                from
                    employer_deposits a,
                    account           b
                where
                        a.entrp_id = b.entrp_id
                    and b.account_type = 'POP'
                group by
                    to_char(check_date, 'YYYY'),
                    to_char(check_date, 'MON'),
                    to_char(check_date, 'MM')
            ) loop
                l_record_t.check_year := x.check_year;
                l_record_t.check_mon := x.check_mon;
                l_record_t.check_mm := x.check_mm;
                l_record_t.setup_fee := x.setup_fee;
                l_record_t.monthly_fee := x.monthly_fee;
                l_record_t.other_fee := x.other_fee;
                l_record_t.renewal_fee := 0;
                pipe row ( l_record_t );
            end loop;
        end if;

    end get_revenue_summary;

    function get_approved_member (
        p_entrp_id     in number,
        p_batch_number in number,
        p_plan_type    in varchar2
    ) return member_t
        pipelined
        deterministic
    is
        l_record_t member_row;
    begin
        for x in (
            select
                replace(a.ssn, '-')                                              ssn,
                a.first_name,
                a.middle_name,
                a.last_name,
                strip_bad(a.phone_day)                                           day_phone,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.email,
                to_char(a.birth_date, 'MMDDYYYY')                                birth_date,
                to_char(c.effective_date, 'MMDDYYYY')                            effective_date,
                c.annual_election,
                pc_person.get_division_name(a.pers_id)                           division_name,
                pc_benefit_plans.get_deductible(c.ben_plan_id_main, b.acc_id)    deductible,
                pc_benefit_plans.get_cov_tier_name(c.ben_plan_id_main, b.acc_id) cov_tier_name,
                to_char(c.effective_end_date, 'MM/DD/YYYY')                      effective_end_date,
                c.plan_start_date,
                c.plan_end_date,
                b.acc_id,
                c.ben_plan_id
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c,
                ben_plan_approvals        at
            where
                    at.batch_number = p_batch_number
                and at.entrp_id = p_entrp_id
                and a.entrp_id = at.entrp_id
                and at.ben_plan_id = c.ben_plan_id
                and at.status = 'A'
                and c.plan_type = p_plan_type
                and c.status = 'A'
                and a.pers_id = b.pers_id
                and b.acc_id = c.acc_id
            order by
                last_name
        ) loop
            l_record_t.ssn := x.ssn;
            l_record_t.first_name := x.first_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.last_name := x.last_name;
            l_record_t.day_phone := x.day_phone;
            l_record_t.address := x.address;
            l_record_t.city := x.city;
            l_record_t.state := x.state;
            l_record_t.zip := x.zip;
            l_record_t.email := x.email;
            l_record_t.birth_date := x.birth_date;
            l_record_t.effective_date := x.effective_date;
            l_record_t.annual_election := x.annual_election;
            l_record_t.division_name := x.division_name;
            l_record_t.deductible := x.deductible;
            l_record_t.cov_tier_name := x.cov_tier_name;
            l_record_t.effective_end_date := x.effective_end_date;
            l_record_t.plan_start_date := to_char(x.plan_start_date, 'mm/dd/yyyy');
            l_record_t.plan_end_date := to_char(x.plan_end_date, 'mm/dd/yyyy');
            l_record_t.pay_cycle := null;
            l_record_t.first_payroll_date := null;
            l_record_t.pay_contribution := null;
            for xx in (
                select distinct
                    pay_cycle,
                    first_payroll_date,
                    pay_contrb
                from
                    pay_details
                where
                        ben_plan_id = x.ben_plan_id
                    and acc_id = x.acc_id
            ) loop
                l_record_t.pay_cycle := xx.pay_cycle;
                l_record_t.first_payroll_date := xx.first_payroll_date;
                l_record_t.pay_contribution := xx.pay_contrb;
            end loop;

            pipe row ( l_record_t );
        end loop;
    end get_approved_member;

    function get_enrollee_balance_rep (
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_ben_plan_id   in number,
        p_division_code in varchar2
    ) return enrollee_balance_t
        pipelined
        deterministic
    is
        l_record_t      enrollee_balance_row;
        l_division_code varchar2(30);
    begin
        if l_division_code = 'ALL_DIVISION' then
            l_division_code := null;
        end if;
        for x in (
            select
                acc_num,
                first_name,
                last_name,
                to_char(end_date, 'MM/DD/YYYY')                                                    termination_date,
                to_char(start_date, 'MM/DD/YYYY')                                                  as plan_start_date,
                annual_election,
                pc_account.current_hrafsa_balance(acc_id, p_start_date, p_end_date, plan_start_date, plan_end_date,
                                                  plan_type)                                       acc_balance,
                pc_fin.contribution_ytd(acc_id, account_type, plan_type, p_start_date, p_end_date) as deposit,
                pc_fin.disbursement_ytd(acc_id, account_type, plan_type, null, p_start_date,
                                        p_end_date)                                                as disbursement,
                plan_type_meaning,
                plan_type,
                division_code,
                division_name
            from
                fsa_hra_employees_v
            where
                    entrp_id = p_entrp_id
                and ben_plan_id_main = p_ben_plan_id
                and ( division_code is null
                      or p_division_code is null
                      or division_code = nvl(p_division_code, division_code) )
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.first_name := x.first_name;
            l_record_t.last_name := x.last_name;
            l_record_t.termination_date := x.termination_date;
            l_record_t.plan_start_date := x.plan_start_date;
            l_record_t.annual_election := x.annual_election;
            l_record_t.acc_balance := x.acc_balance;
            l_record_t.deposit := x.deposit;
            l_record_t.disbursement := x.disbursement;
            l_record_t.plan_type_meaning := x.plan_type_meaning;
            l_record_t.plan_type := x.plan_type;
            l_record_t.division_code := x.division_code;
            l_record_t.division_name := x.division_name;
            pipe row ( l_record_t );
        end loop;

    end get_enrollee_balance_rep;
  /*** FSA non discrimination testing report ***/

    function get_fsa_ndt_member (
        p_entrp_id in number
    ) return member_t
        pipelined
        deterministic
    is
        l_record_t member_row;
    begin
        for x in (
            select distinct
                replace(a.ssn, '-')                    ssn,
                a.first_name,
                a.middle_name,
                a.last_name,
                pc_person.get_division_name(a.pers_id) division_name
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.entrp_id = p_entrp_id
                and a.pers_id = b.pers_id
                and b.acc_id = c.acc_id
                and c.plan_type in ( 'FSA', 'LPF', 'DCA' )
                and c.status = 'A'
                and c.plan_end_date > sysdate
            order by
                last_name
        ) loop
            l_record_t.ssn := x.ssn;
            l_record_t.first_name := x.first_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.last_name := x.last_name;
            l_record_t.division_name := x.division_name;
            pipe row ( l_record_t );
        end loop;
    end get_fsa_ndt_member;

  /*** FSA non discrimination testing report ***/

    function get_hra_ndt_member (
        p_entrp_id in number
    ) return member_t
        pipelined
        deterministic
    is
        l_record_t member_row;
    begin
        for x in (
            select distinct
                replace(a.ssn, '-')                    ssn,
                a.first_name,
                a.middle_name,
                a.last_name,
                pc_person.get_division_name(a.pers_id) division_name
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.entrp_id = p_entrp_id
                and a.pers_id = b.pers_id
                and b.acc_id = c.acc_id
                and c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                and c.status = 'A'
                and c.plan_end_date > sysdate
            order by
                last_name
        ) loop
            l_record_t.ssn := x.ssn;
            l_record_t.first_name := x.first_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.last_name := x.last_name;
            l_record_t.division_name := x.division_name;
            pipe row ( l_record_t );
        end loop;
    end get_hra_ndt_member;

    function f_pending_doc_hrafsa_claims (
        p_acc_id in number
    ) return claim_t
        pipelined
        deterministic
    is
        l_record claim_row;
    begin
        for x in (
            select
                claim_id
            from
                claimn  a,
                account b
            where
                    acc_id = p_acc_id
                and a.pers_id = b.pers_id
                and a.claim_status = 'PENDING_DOC'
            order by
                claim_id desc
        ) loop
            l_record.claim_id := x.claim_id;
            pipe row ( l_record );
        end loop;
    end f_pending_doc_hrafsa_claims;

    procedure write_funding_report_file is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'funding_invoice_report'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'w');

        l_line := 'Employer Name, Account Number, Product , Invoice #, Invoice Amount';
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select distinct
                '"'
                || pc_entrp.get_entrp_name(b.entrp_id)
                || '"' employer_name,
                b.acc_num,
                c.invoice_id,
                d.plan_type,
                d.invoice_amount
            from
                ben_plan_enrollment_setup a,
                account                   b,
                ar_invoice                d,
                payroll_contribution      c
            where
                    a.acc_id = b.acc_id
                and c.entrp_id = b.entrp_id
                and c.invoice_id is not null
                and c.invoice_id = d.invoice_id
                and trunc(d.invoice_date) = trunc(sysdate)
        ) loop
            l_line := x.employer_name
                      || ','
                      || x.acc_num
                      || ','
                      || x.plan_type
                      || ','
                      || x.invoice_id
                      || ','
                      || x.invoice_amount;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_funding_report_file;

    procedure write_detail_funding_file is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'funding_detail_invoice'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'w');

        l_line := 'Employer Name, Account Number,Person Name,Employee Account Number, Plan, Invoice #, Invoice Amount,EE Payroll amount '
        ;
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select distinct
                '"'
                || pc_entrp.get_entrp_name(b.entrp_id)
                || '"'    employer_name,
                b.acc_num,
                c.invoice_id,
                c.plan_type,
                d.invoice_amount,
                e.acc_num ee_acc_num,
                '"'
                || pc_person.get_person_name(e.pers_id)
                || '"'    person_name,
                c.payroll_amount
            from
                ben_plan_enrollment_setup a,
                account                   b,
                ar_invoice                d,
                payroll_contribution      c,
                account                   e
            where
                    a.acc_id = b.acc_id
                and c.entrp_id = b.entrp_id
                and c.invoice_id is not null
                and c.invoice_id = d.invoice_id
                and e.acc_id = c.acc_id
                and trunc(d.invoice_date) = trunc(sysdate)
        ) loop
            l_line := x.employer_name
                      || ','
                      || x.acc_num
                      || ','
                      || x.person_name
                      || ','
                      || x.ee_acc_num
                      || ','
                      || x.plan_type
                      || ','
                      || x.invoice_id
                      || ','
                      || x.invoice_amount
                      || ','
                      || x.payroll_amount;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_detail_funding_file;

    procedure write_funding_exception_file is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(3200);
    begin
        l_utl_id := utl_file.fopen('CLAIM_DIR',
                                   'funding_exception'
                                   || to_char(sysdate, 'mmddyyyy')
                                   || '.csv',
                                   'w');

        l_line := 'Employer Name, Account Number, Plan, Plan Start Date, Plan End Date, Error ';
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select distinct
                '"'
                || pc_entrp.get_entrp_name(a.entrp_id)
                || '"' employer_name,
                a.acc_id,
                b.acc_num,
                a.plan_type,
                a.plan_start_date,
                a.plan_end_date,
                a.funding_options
            from
                ben_plan_enrollment_setup a,
                scheduler_master          c,
                account                   b
            where
                    a.acc_id = c.acc_id
                and a.acc_id = b.acc_id
                and c.payment_end_date > sysdate
                and a.plan_end_date > sysdate
                and a.plan_type = c.plan_type
                and a.funding_options <> 'PUF'
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.funding_options = 'PUF'
                        and a.acc_id = d.acc_id
                        and a.plan_start_date = d.plan_start_date
                        and a.plan_end_date = d.plan_end_date
                )
            order by
                1
        ) loop
            l_line := x.employer_name
                      || ','
                      || x.acc_num
                      || ','
                      || x.plan_type
                      || ','
                      || x.plan_start_date
                      || ','
                      || x.plan_end_date
                      || ','
                      || 'Check if Plan Should set up with Funding Option ';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        for x in (
            select distinct
                '"'
                || pc_entrp.get_entrp_name(c.entrp_id)
                || '"' employer_name,
                b.acc_num,
                c.plan_type
            from
                payroll_contribution c,
                account              b
            where
                    c.entrp_id = b.entrp_id
                and invoice_id is null
                and processed_flag = 'Y'
                and not exists (
                    select
                        *
                    from
                        invoice_parameters i
                    where
                            c.entrp_id = i.entity_id
                        and i.entity_type = 'EMPLOYER'
                        and i.invoice_type = 'FUNDING'
                )
        ) loop
            l_line := x.employer_name
                      || ','
                      || x.acc_num
                      || ','
                      || x.plan_type
                      || ',,,Employer is not setup with Funding Invoice';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end write_funding_exception_file;

    function get_suspended_cards_rep (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return suspended_cards_t
        pipelined
        deterministic
    is
        l_record_t suspended_cards_row_t;
    begin
        for x in (
            select
                ac.acc_num,
                p.first_name,
                p.last_name,
                p.middle_name,
                e.name,
                (
                    select
                        count(*)
                    from
                        claimn c
                    where
                            c.pers_id = p.pers_id
                        and c.unsubstantiated_flag = 'Y'
                        and c.pay_reason = 13
                )                                      no_of_claims,
                ac.acc_id,
                p.pers_id,
                p.entrp_id,
                '****-****-****-'
                || substr(cd.card_number, 13, 4)       card_number,
                pc_person.get_division_name(p.pers_id) division_code
            from
                person     p,
                card_debit cd,
                enterprise e,
                account    ac
            where
                    p.pers_id = cd.card_id
                and ac.pers_id = p.pers_id
                and p.entrp_id = e.entrp_id
                and cd.status in ( 4, 6 )
                and p.entrp_id = nvl(p_entrp_id, p.entrp_id)
                and ( p.division_code is null
                      or p.division_code = decode(p_division_code, 'ALL_DIVISION', p.division_code, p_division_code)
                      or p_division_code is null )
                and ac.account_type in ( 'HRA', 'FSA' )
            order by
                e.name
        ) loop
            if x.no_of_claims > 0 then
                l_record_t.acc_num := x.acc_num;
                l_record_t.first_name := x.first_name;
                l_record_t.last_name := x.last_name;
                l_record_t.middle_name := x.middle_name;
                l_record_t.employee_name := x.first_name
                                            || ' '
                                            || x.last_name;
                l_record_t.employer_name := x.name;
                l_record_t.no_of_unsub := x.no_of_claims;
                l_record_t.acc_id := x.acc_id;
                l_record_t.pers_id := x.pers_id;
                l_record_t.entrp_id := x.entrp_id;
                l_record_t.card_number := x.card_number;
                l_record_t.division_code := x.division_code;
                pipe row ( l_record_t );
            end if;
        end loop;
    end get_suspended_cards_rep;

    function get_renewal_template (
        p_entrp_id in number
    ) return member_t
        pipelined
        deterministic
    is
        l_record_t member_row;
        l_display  varchar2(1) := 'N';
    begin
   -- Added for Combining Tickets (5037,10544,9735) Swamy 10/11/2021
   -- 10544 => Renewal template should not display the employees who's most recent plan is terminated
        for x in (
            select
                a.first_name,
                a.middle_name,
                a.last_name,
                b.acc_num,
                b.acc_id
            from
                person  a,
                account b
            where
                    a.entrp_id = p_entrp_id
                and a.pers_id = b.pers_id
            order by
                last_name
        ) loop
            l_display := 'N';
               -- Check how many plans are there for an account ex in HRA there could be HRA and HRP
               -- Check if all the plans are terminated?, if any one plan is active we should display
               -- Check if any one of the plan is active(active means if the plan end date is less than sysdate and it should fall between the renewal range)
               -- Check to see if the plan status is active or Inactive, display only active plan status.
            for k in (
                select
                    max(e.ben_plan_id), /*MAX(e.termination_req_date)*/
                    e.plan_type
                from
                    ben_plan_enrollment_setup e
                where
                        e.acc_id = x.acc_id
                    and e.status = 'A'
                    and e.termination_req_date is null
                    and ( ( trunc(e.plan_end_date) > trunc(sysdate)
                            or ( trunc(e.plan_end_date) between trunc(sysdate) and trunc(sysdate) + pc_web_er_renewal.g_prior_days )   -- prior 180 days
                            or ( trunc(sysdate) between trunc(e.plan_end_date) and trunc(e.plan_end_date) + pc_web_er_renewal.g_after_days
                            ) ) )  -- after 90 days
                group by
                    e.plan_type
            ) loop
                l_display := 'Y';
                exit;
            end loop;

            if l_display = 'Y' then
                l_record_t.first_name := x.first_name;
                l_record_t.middle_name := x.middle_name;
                l_record_t.last_name := x.last_name;
                l_record_t.acc_num := x.acc_num;
                pipe row ( l_record_t );
            end if;

        end loop;

   -- Commented for Tickets (5037,10544,9735) Swamy 10/11/2021
  /* FOR X IN(SELECT    A.FIRST_NAME
                            ,  A.MIDDLE_NAME
                            ,  A.LAST_NAME
                            ,  B.ACC_NUM
                      FROM   PERSON a
                         ,   ACCOUNT B
                         ,   BEN_PLAN_ENROLLMENT_SETUP c
                         ,   BEN_PLAN_ENROLLMENT_SETUP D
                      WHERE  A.ENTRP_ID = P_ENTRP_ID
                      AND    A.PERS_ID = B.PERS_ID
                      AND    B.ACC_ID = C.ACC_ID
                      AND    c.status = 'A'
                      AND    c.effective_end_date IS NULL  Ticket#5037.Terminated plans should not show up
                      --AND    C.PLAN_END_DATE  < SYSDATE  --sk Commented 08_29_2017 to display all employees even if the plan is still active
                      AND    c.termination_req_date is NULL -- Ticket#5037
                      AND    D.ENTRP_ID = A.ENTRP_ID
                      AND    D.PLAN_TYPE = C.PLAN_TYPE
                      AND   NOT EXISTS ( SELECT * FROM BEN_PLAN_ENROLLMENT_SETUP E
                                      WHERE E.BEN_PLAN_ID  = C.BEN_PLAN_ID_MAIN   -- Replaced D.BEN_PLAN_ID with E.BEN_PLAN_ID by Swamy for Ticket#9735 on 12/03/2021
                                      AND   E.ACC_ID = B.ACC_ID )
                             GROUP  by A.FIRST_NAME
                            ,  A.MIDDLE_NAME
                            ,  A.LAST_NAME
                            ,  B.ACC_NUM
                      ORDER BY LAST_NAME)
   LOOP

                l_record_t.first_name       := x.first_name;
                l_record_t.middle_name      := x.middle_name;
                l_record_t.last_name        := x.last_name;
                l_record_t.acc_num          :=    x.acc_num;
                PIPE ROW(l_record_t);
   END LOOP;*/
    end get_renewal_template;

/* Procedure created by Jagadeesh for Ticket#  */
/*  -- This Development is on Hold so commenting it
PROCEDURE Monthly_contri_audit_detail( p_start_date date default NULL
                                      ,p_end_date date  default NULL)

IS
   -- Variable Declaration
    V_Insert_ID           VARCHAR2(10);
    V_period_Start        DATE;
    V_period_END          DATE;
    v_start               DATE;
    v_source              VARCHAR2(10);
    v_recurring_flag      VARCHAR2(10);
    v_reporting_method    VARCHAR2(20);
    v_css                 VARCHAR2(100);
    v_Termination_Method  VARCHAR2(20);
    v_fund_setup          VARCHAR2(100);

BEGIN
--pc_log.log_error('Insert_Sales_Commission_Report','In Proc');

    IF p_start_date  IS NULL THEN
         -- Start date of the Previous month
        V_period_Start  := TRUNC(Last_Day(ADD_MONTHS(sysdate,-2))+1);
        -- End Date of the Previous month
        V_period_END    := TRUNC(Last_Day(ADD_MONTHS(sysdate,-1)));
        -- ID to indentify the previous month and previous year
        V_Insert_ID     := to_char(V_period_Start,'MMYYYY');
    ELSE
        -- Start date of the Previous month
        V_period_Start  := TRUNC(p_start_date);
        -- End Date of the Previous month
        V_period_END    := TRUNC( NVL( p_end_date, Last_Day(p_start_date)));
        -- ID to indentify the previous month and previous year
        V_Insert_ID     := to_char(V_period_Start,'MMYYYY');

    END IF ;

    -- Before inserting the previous months records, delete all the previous months records.
    Delete from Monthly_contri_audit_detail where Insert_ID = v_Insert_ID;

-- Query for FSA/HRA
FOR I IN (SELECT e.name
                ,a.acc_num
                ,a.Enrollment_Source
                ,b.plan_type
                ,b.funding_type
                ,b.funding_options
                ,b.ben_plan_name
                ,b.plan_start_date
                ,b.plan_end_date
                ,b.ben_plan_id
                ,b.acc_id
                ,b.entrp_id
                ,b.product_type
                ,PC_SALES_TEAM.GET_CUST_SRVC_REP_NAME_FOR_ER(e.entrp_id) CSS_NAME
                ,pc_lookups.GET_meaning(b.funding_options,DECODE(b.product_type,'FSA','FSA_FUNDING_OPTION','HRA','HRA_FUNDING_OPTION')) fund_setup
            FROM account a, enterprise e, ben_plan_enrollment_setup b
           WHERE a.entrp_id = e.entrp_id
             AND a.account_status = 1
             AND a.acc_id = b.acc_id
             AND b.plan_start_date <= V_period_Start
             AND b.plan_end_date >= V_period_END
             and b.entrp_id =7647
             AND b.status = 'A'
             AND a.account_Type in ('FSA','HRA')
             order by plan_type)
   LOOP

     -- v_start := to_date(('15'||v_insert_id),'ddmonyyyy');
   --   db_tool('v_start :='||v_start);
      FOR J IN (select s.source , s.recurring_flag
	              FROM scheduler_master s
				 WHERE s.acc_id = i.acc_id
				   AND s.payment_start_date >= V_period_Start
				   AND s.payment_end_date <= V_period_END
                   AND s.plan_type = i.plan_type
                   order by creation_date desc) LOOP
         v_source := UPPER(j.source);
         v_recurring_flag := NVL(UPPER(j.recurring_flag),'N');
         EXIT;
      END LOOP;

    IF i.plan_type = 'HRA' THEN
       v_reporting_method := 'Manual Reporting';
    ELSIF v_source = 'EDI' THEN
       v_reporting_method := 'EDI Contribution Reporting';
    ELSIF v_source = 'ONLINE' THEN
      IF v_recurring_flag = 'Y' THEN
         v_reporting_method := 'Online Calendar Reporting - Recurring';
      Elsif v_recurring_flag = 'N' THEN
         v_reporting_method := 'Online Calendar Reporting - Nonrecurring';
      END IF;
    ELSIF v_source = 'SAM' THEN
      IF v_recurring_flag = 'Y' THEN
         v_reporting_method := 'Schedular-Recurring';
      Elsif v_recurring_flag = 'N' THEN
         v_reporting_method := 'One time posting';
      END IF;
    ELSE
      v_reporting_method := 'No Enrollments';
      v_Termination_Method := 'No Enrollments';
    END IF;

    IF NVL(v_Termination_Method,'*') <> '*' THEN
		FOR k in (SELECT Decode(Enrollment_Source,'EDI','EDI Eligibility Termination','PAPER','Manual Termination','ONLINE','Online Termination Reporting') enrollment_source
		            FROM mass_enrollments
				   WHERE entrp_acc_id = i.acc_id
				     AND termination_date is not null
                     AND process_status = 'S') LOOP
		  v_Termination_Method := k.enrollment_source;
		END LOOP;
    END IF;

    INSERT INTO Monthly_contri_audit_detail
               (Account_Name
               ,Accont_Number
               ,Plan_Type
               ,Fund_Setup
               ,Contribution_Reporting_Method
               ,Enrollment_Reporting_Method
               ,Termination_Method
               ,Client_Services_Specialist
               ,Insert_ID
               ,Report_Date
               ,ben_plan_id
               ,Creation_Date
               ,created_by
               )
        VALUES
                (I.Name
                ,I.acc_num
                ,I.plan_type
                ,I.fund_setup --funding_type
                ,v_reporting_method
                ,Decode(I.Enrollment_Source,'EDI','EDI Eligibility Reporting','PAPER','Manual Enrollment Method','Online Enrollment Method')
                ,v_Termination_Method
                ,I.CSS_NAME
                ,V_Insert_ID
                ,I.plan_start_date
                ,I.ben_plan_id
                ,SYSDATE
                ,0
                 );

END LOOP;

EXCEPTION
    WHEN OTHERS THEN
         pc_log.log_error('Monthly_contri_audit_detail OTHERS ',SQLERRM);
END Monthly_contri_audit_detail;
*/
-- Added by Swamy for Ticket#9669
    function get_welcome_letters (
        p_acc_num      in varchar2,
        p_flg_employer in varchar2
    ) return welcome_letter_t
        pipelined
        deterministic
    is

        l_record_t      welcome_letter_row_t;
        l_today         varchar2(20);
        l_er_name       varchar2(200);
        l_er_contact    varchar2(200);
        l_address       varchar2(500);
        l_city          varchar2(200);
        l_acc_num       varchar2(200);
        l_year          varchar2(200);
        l_lang_perf     varchar2(200);
        l_template_name varchar2(200);
        l_account_type  account.account_type%type;
    begin
        for i in (
            select
                account_type
            from
                account
            where
                acc_num = p_acc_num
        ) loop
            l_account_type := i.account_type;
        end loop;

        if nvl(p_flg_employer, '*') = 'E' then
            if l_account_type = 'HSA' then
     -- For HSA
                for j in (
                    select
                        today,
                        er_name,
                        entrp_contact,
                        address,
                        city,
                        account_number,
                        to_char(sysdate, 'YYYY') year,
                        lang_perf,
                        template_name
                    from
                        template_employer_hsa_wel_letr
                    where
                        account_number = p_acc_num
                ) loop
                    l_record_t.today := j.today;
                    l_record_t.er_name := j.er_name;
                    l_record_t.er_contact := j.entrp_contact;
                    l_record_t.address := j.address;
                    l_record_t.city := j.city;
                    l_record_t.acc_num := j.account_number;
                    l_record_t.year := j.year;
         --l_record_t.account_type  := j.account_type;
                    l_record_t.lang_perf := j.lang_perf;
                    l_record_t.template_name := j.template_name;
                    pipe row ( l_record_t );
                end loop;

            elsif l_account_type in ( 'HRA', 'FSA' ) then
                for j in (
                    select
                        today,
                        replace(er_name, '&', 'and') er_name,
                        er_contact,
                        address,
                        city,
                        account_number,
                        to_char(sysdate, 'YYYY')     year,
                        account_type,
                        lang_perf,
                        template_name
                    from
                        template_employer_hra_wel_letr
                    where
                        account_number = p_acc_num
                ) loop
                    l_record_t.today := j.today;
                    l_record_t.er_name := j.er_name;
                    l_record_t.er_contact := j.er_contact;
                    l_record_t.address := j.address;
                    l_record_t.city := j.city;
                    l_record_t.acc_num := j.account_number;
                    l_record_t.year := j.year;
                    l_record_t.account_type := j.account_type;
                    l_record_t.lang_perf := j.lang_perf;
                    l_record_t.template_name := j.template_name;
                    pipe row ( l_record_t );
                end loop;
            end if;

        elsif nvl(p_flg_employer, '*') = 'I' then
            if l_account_type = 'HSA' then
                for j in (
                    select
                        today,
                        person_name,
                        address,
                        city,
                        account_number,
                        initial_contrib,
                        month_setup,
                        employer,
                        single_contrib,
                        family_contrib,
                        to_char(sysdate, 'YYYY') year,
                        template_name,
                        lang_perf
                    from
                        template_subscrib_hsa_wel_letr --subscriber_welcome_letter
                    where
                        account_number = p_acc_num
                ) loop
                    l_record_t.today := j.today;
                    l_record_t.individual_name := j.person_name;
        --l_record_t.er_contact    := j.entrp_contact;
                    l_record_t.address := j.address;
                    l_record_t.city := j.city;
                    l_record_t.acc_num := j.account_number;
                    l_record_t.initial_contrib := j.initial_contrib;
                    l_record_t.month_setup := j.month_setup;
                    l_record_t.er_name := j.employer;
                    l_record_t.single_contrib := j.single_contrib;
                    l_record_t.family_contrib := j.family_contrib;
                    l_record_t.year := j.year;
                    l_record_t.account_type := l_account_type;
                    l_record_t.lang_perf := j.lang_perf;
                    l_record_t.er_name := j.employer;
                    l_record_t.template_name := j.template_name;
                    pipe row ( l_record_t );
                end loop;

            elsif l_account_type in ( 'HRA', 'FSA' ) then
                for j in (
                    select
                        today,
                        person_name,
                        address,
                        city,
                        account_number,
                        employer,
                        to_char(sysdate, 'YYYY') year,
                        account_type,
                        lang_perf,
                        template_name
                    from
                        template_subscrib_hra_wel_letr
                    where
                        account_number = p_acc_num
                ) loop
                    l_record_t.today := j.today;
                    l_record_t.individual_name := j.person_name;
                    l_record_t.er_name := j.employer;
       -- l_record_t.er_contact    := j.er_contact;
                    l_record_t.address := j.address;
                    l_record_t.city := j.city;
                    l_record_t.acc_num := j.account_number;
                    l_record_t.year := j.year;
                    l_record_t.account_type := j.account_type;
                    l_record_t.lang_perf := j.lang_perf;
                    l_record_t.template_name := j.template_name;
                    pipe row ( l_record_t );
                end loop;
            end if;

/*elsif  nvl(p_flg_employer,'*') = 'B' then
       FOR j IN (SELECT today,broker_name, NVL(address,' ') address, NVL(city,' ') city, ltrim(SUBSTR(broker_name,1,4)||'Broker') account_number
         FROM broker_welcome_letter_v
        WHERE TRUNC(start_date) = TRUNC(SYSDATE)
          AND account_number(+) = p_Acc_num) loop
		l_record_t.today         := j.today;
        l_record_t.er_name       := j.broker_name;
        l_record_t.address       := j.address;
        l_record_t.city          := j.city;
        l_record_t.acc_num       := j.account_number;

		PIPE ROW(l_record_t);

        end loop;*/
        end if;

    exception
        when others then
            pc_log.log_error('get_welcome_letters OTHERS ', sqlerrm);
    end get_welcome_letters;

-- Added by Swamy for Ticket#9669
    function get_account_details (
        p_acc_num      in varchar2,
        p_flg_employer in varchar2
    ) return account_t
        pipelined
        deterministic
    is
        l_record_t   account_row_t;
        l_entrp_code enterprise.entrp_code%type;
        l_ssn        person.ssn%type;
    begin
        pc_log.log_error('get_account_details p_flg_employer ', p_flg_employer);
        if nvl(p_flg_employer, '*') = 'E' then
            for j in (
                select
                    a.account_type,
                    e.name,
                    entrp_code
                from
                    account    a,
                    enterprise e
                where
                        a.entrp_id = e.entrp_id
                    and a.acc_num = p_acc_num
            ) loop
                l_record_t.account_type := j.account_type;
                l_record_t.name := j.name;
                l_entrp_code := j.entrp_code;
            end loop;

            pc_log.log_error('get_account_details p_flg_employer ', p_flg_employer);
            for i in (
                select
                    a.acc_num,
                    u.email
                from
                    account      a,
                    enterprise   e,
                    online_users u
                where
                        a.entrp_id = e.entrp_id
                    and e.entrp_code = l_entrp_code
                    and u.tax_id = e.entrp_code
                    and u.user_type = 'E'
                    and u.user_status = 'A'
                    and u.email is not null
            ) loop
                l_record_t.email := i.email;
            end loop;

            if nvl(l_record_t.email, '*') = '*' then
                l_record_t.error_message := 'Employer don¿t have registered email address, please select Letter to procced';
            end if;

            pipe row ( l_record_t );
        else
            for j in (
                select
                    a.account_type,
                    ( p.first_name
                      || ' '
                      || p.middle_name
                      || ' '
                      || p.last_name ) name,
                    p.ssn,
                    p.email
                from
                    account a,
                    person  p
                where
                        a.pers_id = p.pers_id
                    and a.acc_num = p_acc_num
            ) loop
                l_record_t.account_type := j.account_type;
                l_record_t.name := j.name;
                l_ssn := j.ssn;
                l_record_t.email := j.email;
            end loop;

            if nvl(l_record_t.email, '*') = '*' then
                for k in (
                    select
                        email
                    from
                        online_users
                    where
                            format_ssn(tax_id) = l_ssn
                        and user_type = 'S'
                        and user_status = 'A'
                        and email is not null
                ) loop
                    l_record_t.email := k.email;
                end loop;

            end if;

            if nvl(l_record_t.email, '*') = '*' then
                l_record_t.error_message := 'Subscriber don¿t have registered email address, please select Letter to procced';
            end if;

            pipe row ( l_record_t );
        end if;

    exception
        when others then
            pc_log.log_error('get_account_details OTHERS ', sqlerrm);
    end get_account_details;

-- Added by 12157- Claims Aging Report
    function generate_claim_aging_report return claim_aging_t
        pipelined
        deterministic
    is
        l_record_t               claim_aging_row;
        l_check_sent_to_cnb_days number := 0;
    begin
        for j in (
            select
                received_days,
                claim_status,
                no_of_days,
                emp_name,
                claim_id,
                acc_num,
                pay_reason,
                payment_type
            from
                (
                    select
                        round(sysdate - claim_date_start)   received_days,
                        case
                            when claim_status = 'APPROVED'            then
                                'Waiting to be released by Benefits team'
                            when claim_status = 'APPROVED_FOR_CHEQUE' then
                                'Waiting for Funds'  /*Updated by SK on 09/03 on Cora's Request*/
                            when claim_status = 'READY_TO_PAY'        then
                                'Waiting to be paid out'
                            else
                                pc_lookups.get_claim_status(a.claim_status)
                        end                                 claim_status,
                        nvl(
                            case
                                when claim_status = 'APPROVED' then
                                    round(sysdate - approved_date)
                                when claim_status = 'APPROVED_FOR_CHEQUE' then
                                    round(sysdate - greatest(released_date,
                                                             nvl(funds_availability_date, claim_date_start)))
                                when claim_status = 'READY_TO_PAY' then
                                    round(sysdate - payment_release_date)
                            end,
                            0)                              no_of_days,
                        claim_id,
                        b.acc_num,
                        pc_entrp.get_entrp_name(a.entrp_id) emp_name,
                        a.pay_reason,
                        case
                            when a.pay_reason = 19 then
                                'ACH'
                            else
                                'CHECK'
                        end                                 payment_type
                    from
                        claimn  a,
                        account b,
                        account c
                    where
                        claim_status in ( 'APPROVED_FOR_CHEQUE', 'APPROVED', 'READY_TO_PAY' )
                        and b.account_type in ( 'HRA', 'FSA' )
                        and a.pers_id = b.pers_id
                        and c.entrp_id = a.entrp_id
                        and c.end_date is null
                        and a.claim_code not like 'BPS%'
                        and a.entrp_id <> 7963
                        and a.claim_amount > 0
                                          --      AND a.claim_id in (6570078,6581100,6581097,6581098,6581096,6581099,6581101,6581102)
                        and not exists (
                            select
                                *
                            from
                                checks
                            where
                                    entity_id = a.claim_id
                                and status = 'PURGE_AND_REISSUE'
                        )
                        and round(sysdate - claim_date_start) > 5
                )
            where
                no_of_days > 5
            order by
                4,
                2
        ) loop
            l_record_t.emp_name := j.emp_name;
            l_record_t.acc_num := j.acc_num;
            l_record_t.claim_id := j.claim_id;
            l_record_t.claim_status := j.claim_status;
            l_record_t.received_days := j.received_days;
            l_record_t.no_of_days := j.no_of_days;
            l_record_t.payment_type := j.payment_type;
            if j.pay_reason <> 19 then
                l_check_sent_to_cnb_days := 0;
                for c in (
                    select
                        check_number
                    from
                        checks
                    where
                            entity_id = j.claim_id
                        and entity_type = 'CLAIMN'
                        and status = 'SENT'
                ) loop
                    begin
                        select
                            round(sysdate - creation_date)
                        into l_check_sent_to_cnb_days
                        from
                            cnb_check_sent_details
                        where
                            check_number = c.check_number;

                    exception
                        when others then
                            l_check_sent_to_cnb_days := 0;
                    end;

                    if l_check_sent_to_cnb_days > 0 then
                        l_record_t.claim_status := 'waiting for the bank to mail the check';
                        l_record_t.no_of_days := l_check_sent_to_cnb_days;
                    end if;

                end loop;

            end if;

            pipe row ( l_record_t );
        end loop;
    exception
        when others then
            pc_log.log_error('Get_Employer_Info OTHERS ', sqlerrm);
    end generate_claim_aging_report;

end pc_reports_pkg;
/


-- sqlcl_snapshot {"hash":"ee64c0c9aca584bef7f21ddda1ec95fbfad0a1b4","type":"PACKAGE_BODY","name":"PC_REPORTS_PKG","schemaName":"SAMQA","sxml":""}