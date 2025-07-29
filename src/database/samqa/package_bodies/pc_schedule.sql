create or replace package body samqa.pc_schedule as

    function get_divided_amount (
        p_amount    in number,
        p_frequency in varchar2
    ) return number is
        l_amount number;
    begin
        select
            p_amount / (
                case
                    when p_frequency = 'BIANNUALLY' then
                        2
                    when p_frequency = 'ANNUALLY'   then
                        1
                    when p_frequency = 'BIWEEKLY'   then
                        26
                    when p_frequency = 'WEEKLY'     then
                        52
                    when p_frequency = 'BIMONTHLY'  then
                        24
                    when p_frequency = 'MONTHLY'    then
                        12
                    when p_frequency = 'QUARTERLY'  then
                        4
                    else
                        1
                end
            )
        into l_amount
        from
            dual;

        return l_amount;
    end;

    function get_holiday (
        p_acc_id     in number,
        p_trans_date in date
    ) return date is
        l_trans_date date;
        l_holiday    varchar2(1) := 'N';
    begin
        for x in (
            select
                p_trans_date
            from
                holiday_calendar
            where
                    acc_id = nvl((
                        select
                            p_acc_id
                        from
                            holiday_calendar
                        where
                            acc_id = p_acc_id
                    ), 6)
                and trunc(holiday_date) = p_trans_date
        ) loop
            l_holiday := 'Y';
        end loop;

        l_trans_date := p_trans_date;
        if l_holiday = 'Y' then
            l_trans_date := l_trans_date - 1;
        end if;
        if to_char(l_trans_date, 'D') = 1 then
            l_trans_date := l_trans_date - 2;
        end if;

        if to_char(l_trans_date, 'D') = 7 then
            l_trans_date := l_trans_date - 1;
        else
            l_trans_date := l_trans_date;
        end if;

        return l_trans_date;
    end get_holiday;

    procedure generate_calendar (
        p_schedule_id in number,
        p_frequency   in varchar2,
        p_start_date  in date,
        p_end_date    in date,
        p_user_id     in number
    ) is
        l_trans_date_list pc_schedule.schedule_date_table;
        l_trans_dt        date;
        l_cnt             number := 0;
        l_period_list     pc_schedule.schedule_date_table;
    begin
        if p_frequency = 'WEEKLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 52
            )
            select
                period_date
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(p_start_date, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'BIWEEKLY' then
            with data as (
                select
                    2 * level k
                from
                    dual
                connect by
                    level <= 26
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(p_start_date, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'SEMIMONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(trunc(p_start_date, 'MM') + 14,
                                   k) period_date
                    from
                        data
                    union
                    select
                        add_months(
                            last_day(p_start_date),
                            k
                        ) period_date
                    from
                        data
                    where
                        add_months(
                            last_day(p_start_date),
                            k
                        ) > p_start_date
                    order by
                        1
                )
            where
                    period_date >= p_start_date
                and period_date <= p_end_date;

        elsif p_frequency = 'MONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(
                            trunc(p_start_date, 'MM'),
                            k
                        ) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'QUARTERLY' then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        decode(rownum,
                               1,
                               p_start_date,
                               add_months(p_start_date, rownum * 3)) period_date
                    from
                        all_objects
                    where
                        rownum <= 4
                )
            where
                trunc(period_date) <= trunc(p_end_date);

        elsif p_frequency = 'BIANNUALLY' then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        decode(rownum,
                               1,
                               p_start_date,
                               add_months(p_start_date, rownum * 6)) period_date
                    from
                        all_objects
                    where
                        rownum <= 2
                )
            where
                period_date <= p_end_date;

        end if;

        if p_frequency = 'ANNUALLY' then
            l_trans_date_list(l_trans_date_list.count + 1) := p_start_date;
        else
            l_cnt := l_trans_date_list.count;
            if p_frequency = 'BIWEEKLY' then
                l_trans_date_list(l_trans_date_list.count + 1) := p_start_date;
            end if;

            if p_frequency in ( 'QUARTERLY', 'SEMIMONTHLY' ) then
                if p_end_date <> l_trans_date_list(l_trans_date_list.count) then
                    l_trans_date_list(l_trans_date_list.count + 1) := p_end_date;
                end if;
            end if;

        end if;

        for i in 1..l_trans_date_list.count loop
            insert into scheduler_calendar (
                scalendar_id,
                schedule_id,
                period_date,
                created_by,
                last_updated_by
            ) values ( scheduler_calendar_seq.nextval,
                       p_schedule_id,
                       l_trans_date_list(i),
                       p_user_id,
                       p_user_id );

        end loop;

    end;

    function get_schedule_count (
        p_acc_id       in number,
        p_scheduler_id in number,
        freq_code      in varchar2,
        start_dt       date,
        end_dt         date
    ) return number is
        l_no_of_cont      number := 0;
        l_trans_date_list schedule_date_table;
    begin
        select
            count(*)
        into l_no_of_cont
        from
            scheduler_calendar
        where
                schedule_id = p_scheduler_id
            and period_date >= start_dt
            and period_date <= end_dt;

        if l_no_of_cont = 0 then
            l_trans_date_list := get_schedule(p_acc_id, freq_code, start_dt, end_dt);
            l_no_of_cont := l_trans_date_list.count;
        end if;

        return l_no_of_cont;
    end get_schedule_count;

    function get_contributed_amt (
        p_acc_id    in number,
        p_plan_type in varchar2,
        start_dt    date,
        end_dt      date
    ) return number is
        l_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(amount, 0) + nvl(amount_add, 0)) amt
            from
                income
            where
                    plan_type = p_plan_type
                and acc_id = p_acc_id
                and fee_code <> 12
                and trunc(fee_date) >= start_dt
                and trunc(fee_date) <= end_dt
        ) loop
            l_amount := x.amt;
        end loop;

        return l_amount;
    end get_contributed_amt;

    function get_schedule (
        p_acc_id  in number,
        freq_code in varchar2,
        start_dt  date,
        end_dt    date
    ) return schedule_date_table as

        l_trans_dt         date;
        l_day              varchar2(10);
        l_biweek_day       varchar2(10);
        l_biweek_trans_dt  date;
        l_bimonthly_mid_dt date;
   --l_bimonthly_start_dt date;
        l_monthly_trans_dt date;
        l_trans_date_list  schedule_date_table;
        ctr                number := 1;
        month_ctr          number := 0;
        l_date_exist       boolean := false;
        i                  number;
    begin
        l_trans_dt := start_dt;
        if freq_code = 'SEMIMONTHLY1' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(trunc(start_dt, 'MM') + 14,
                                   k) period_date
                    from
                        data
                    union
                    select
                        add_months(
                            last_day(start_dt),
                            k
                        ) period_date
                    from
                        data
                    where
                        add_months(
                            last_day(start_dt),
                            k
                        ) > start_dt
                    order by
                        1
                )
            where
                    period_date >= start_dt
                and period_date <= end_dt;
		-- IF last day is 31, it should add date to pay dates.
            if start_dt = last_day(start_dt) then
                l_trans_date_list(l_trans_date_list.count + 1) := start_dt;
            end if;

        elsif freq_code = 'SEMIMONTHLY2' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(trunc(start_dt, 'MM') + 4,
                                   k) period_date
                    from
                        data
                    union
                    select
                        add_months(trunc(start_dt, 'MM') + 19,
                                   k) period_date
                    from
                        data
                    where
                        add_months(trunc(start_dt, 'MM') + 19,
                                   k) > start_dt
                    order by
                        1
                )
            where
                    period_date >= start_dt
                and period_date <= end_dt;

        elsif freq_code = 'BIWEEKLY' then
            with data as (
                select
                    2 * level k
                from
                    dual
                connect by
                    level <= 26
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(start_dt, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= end_dt;
        --- l_trans_date_list(l_trans_date_list.COUNT+1) := start_dt;  rprabu commented for franco email 12/12/2019
		---l_trans_date_list(l_trans_date_list.COUNT) := start_dt;      ----added by rprabu   for franco email 12/12/2019

          -- Added by Joshi for 10952
            for i in 1..l_trans_date_list.count loop
                if ( l_trans_date_list(i) = start_dt ) then
                    l_date_exist := true;
                end if;
            end loop;

            if l_date_exist = false then
                l_trans_date_list(l_trans_date_list.count + 1) := start_dt;
            end if;

        elsif freq_code = 'QUARTERLY' then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        decode(rownum,
                               1,
                               start_dt,
                               add_months(start_dt, rownum * 3)) period_date
                    from
                        all_objects
                    where
                        rownum <= 4
                )
            where
                trunc(period_date) <= trunc(end_dt);

            if end_dt <> l_trans_date_list(l_trans_date_list.count) then
                l_trans_date_list(l_trans_date_list.count + 1) := end_dt;
            end if;

        elsif freq_code = 'MONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(
                            trunc(start_dt, 'MM'),
                            k
                        ) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= end_dt;

        elsif freq_code = 'WEEKLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 52
            )
            select
                period_date period_date
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(start_dt, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= end_dt;

        end if;

        return l_trans_date_list;
    end get_schedule;

    procedure delete_scheduler (
        p_scheduler_id  in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_processed integer;
    begin
/*
   DELETE FROM scheduler_details WHERE scheduler_id= P_SCHEDULER_ID;
   DELETE FROM scheduler_calendar WHERE schedule_id= P_SCHEDULER_ID;
   DELETE FROM scheduler_master  WHERE scheduler_id= P_SCHEDULER_ID;
*/  /*
        SELECT COUNT(*) INTO l_processed
       FROM SCHEDULER_MASTER  A
       WHERE A.SCHEDULER_ID = P_SCHEDULER_ID
       AND ( (RECURRING_FLAG = 'Y' AND EXISTS (SELECT * FROM scheduler_calendar WHERE SCHEDULE_ID = A.SCHEDULER_ID
              AND TRUNC(PERIOD_DATE) >= TRUNC(SYSDATE)))

    IF   l_processed = 0 THEN
         X_ERROR_MESSAGE := 'The scheduler is already processed. So it can not be deleted' ;
         X_RETURN_STATUS := 'E' ;
    ELSE
       OR ( RECURRING_FLAG = 'N' AND trunc(payment_start_date) >=  trunc(sysdate)));
  */
        update scheduler_master
        set
            payment_start_date = trunc(sysdate),
            status = 'D',
            recurring_flag = 'N',
            recurring_frequency = null,
            last_updated_by = p_user_id,
            last_updated_date = sysdate
        where
            scheduler_id = p_scheduler_id;

        update scheduler_details
        set
            status = 'I',
            last_updated_by = p_user_id,
            last_updated_date = sysdate
        where
            scheduler_id = p_scheduler_id;

        x_return_status := 'S';
        x_error_message := 'Schedule deleted successfully';

   -- END IF;
    exception
        when others then
            x_return_status := 'E';
            x_error_message := 'Schedule can not be deleted. Please contact system administrator';
    end delete_scheduler;

    procedure ins_scheduler (
        p_acc_id               number,
        p_name                 varchar2,
        p_payment_method       varchar2,
        p_payment_type         varchar2,
        p_reason_code          number,
        p_payment_start_date   date,
        p_payment_end_date     date,
        p_recurring_flag       varchar2,
        p_recurring_frequency  varchar2,
        p_amount               number,
        p_fee_amount           number,
        p_bank_acct_id         number,
        p_contributor          number,
        p_plan_type            varchar2,
        p_orig_system_source   varchar2,
        p_orig_system_ref      varchar2,
        p_pay_to_all           varchar2,
        p_pay_to_all_amount    number,
        p_source               varchar2 default 'SAM',
        p_pay_dates            pc_online_enrollment.varchar2_tbl,
        p_user_id              number,
        p_note                 varchar2,
        p_post_prev_pay_period in varchar2 default 'N',   -- Added by Jaggi for 10365
        p_no_of_pay_period     in varchar2 default null,  -- Added by Jaggi for 11365
        x_scheduler_id         out number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) as

        l_total_amount number;
        l_calendar_id  number;
        l_count        number := 0;
        l_entrp_id     number;
        l_note         varchar2(4000);
    begin
    --pc_log.log_error('PC_SCHEDULE - ins_scheduler p_source',p_source);
    --pc_log.log_error('PC_SCHEDULE - ins_scheduler P_NOTE',P_NOTE);
        x_return_status := 'S';
        for x in (
            select
                entrp_id
            from
                account
            where
                    acc_id = p_acc_id
                and entrp_id is not null
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        for x in (
            select
                calendar_id
            from
                calendar_master
            where
                    calendar_type = 'PAYROLL_CONTRIBUTION'
                and entrp_id = l_entrp_id
        ) loop
            l_calendar_id := x.calendar_id;
        end loop;

        if l_calendar_id is null then
            insert into calendar_master values ( calendar_seq.nextval,
                                                 'PAYROLL_CONTRIBUTION',
                                                 l_entrp_id,
                                                 sysdate,
                                                 0,
                                                 sysdate,
                                                 0,
                                                 null ) returning calendar_id into l_calendar_id;

        end if;

    -- pc_log.log_error('PC_SCHEDULE - ins_scheduler P_NOTE',P_NOTE);
        insert into scheduler_master (
            scheduler_id,
            acc_id,
            scheduler_name,
            payment_method,
            payment_type,
            reason_code,
            payment_start_date,
            payment_end_date,
            recurring_flag,
            recurring_frequency,
            amount,
            fee_amount,
            bank_acct_id,
            contributor,
            plan_type,
            orig_system_source,
            orig_system_ref,
            pay_to_all,
            pay_to_all_amount,
            note,
            created_by,
            creation_date,
            last_updated_by,
            last_updated_date,
            calendar_id,
            source,
            post_prev_pay_period, -- Added by Jaggi for 10365
            no_of_pay_period
        ) values ( scheduler_seq.nextval,
                   p_acc_id,
                   p_name,
                   p_payment_method,
                   p_payment_type,
                   p_reason_code,
                   p_payment_start_date,
                   p_payment_end_date,
                   p_recurring_flag,
                   p_recurring_frequency,
                   p_amount,
                   p_fee_amount,
                   p_bank_acct_id,
                   p_contributor,
                   p_plan_type,
                   p_orig_system_source,
                   p_orig_system_ref,
                   p_pay_to_all,
                   p_pay_to_all_amount,
                   decode(p_source,
                          'ONLINE',
                          'Generated from Online '
                          || to_char(sysdate, 'mm/dd/yyyy')
                          || ' '
                          || nvl(p_note, ' '),
                          p_note),
                   p_user_id,
                   sysdate,
                   p_user_id,
                   sysdate,
                   l_calendar_id,
                   p_source,
                   p_post_prev_pay_period, -- Added by Jaggi for 1036
                   p_no_of_pay_period ) returning scheduler_id into x_scheduler_id;

        if
            p_recurring_flag = 'Y'
            and p_recurring_frequency is not null
            and p_payment_end_date is not null
            and p_payment_start_date is not null
        then
        -- added by Joshi for Payroll contribution. date array will be sent from php.
            if p_source = 'ONLINE' then
                pc_schedule.generate_calendar(
                    p_schedule_id => x_scheduler_id,
                    p_paydates    => p_pay_dates,
                    p_user_id     => p_user_id
                );

                if p_payment_method = 'PAYROLL' then -- Added by Joshi for 9382
                    pc_schedule.copy_pay_calendar(x_scheduler_id); -- Added by Joshi for fixing calender issue.7153
                end if;
            else
                pc_schedule.generate_calendar(
                    p_schedule_id => x_scheduler_id,
                    p_frequency   => p_recurring_frequency,
                    p_start_date  => p_payment_start_date,
                    p_end_date    => p_payment_end_date,
                    p_user_id     => p_user_id
                );

                pc_schedule.copy_pay_calendar(x_scheduler_id);
            end if;
        end if;

        if p_pay_to_all = 'Y' then
            insert into scheduler_details (
                scheduler_detail_id,
                scheduler_id,
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date
            )
                select
                    scheduler_detail_seq.nextval,
                    x_scheduler_id,
                    a.acc_id,
                    p_pay_to_all_amount,
                    0,
                    0,
                    0,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    sysdate
                from
                    account                   a,
                    person                    b,
                    ben_plan_enrollment_setup c
                where
                        a.pers_id = b.pers_id
                    and b.entrp_id = p_contributor
                    and c.acc_id = a.acc_id
                    and a.account_status <> 4
                    and nvl(c.effective_end_date, sysdate) >= sysdate
                    and c.status = 'A'
                    and c.plan_type = p_plan_type;

            if sql%rowcount > 0 then
                select
                    sum(er_amount)
                into l_total_amount
                from
                    scheduler_details
                where
                    scheduler_id = x_scheduler_id;

                if l_total_amount > 0 then
                    update scheduler_master
                    set
                        amount = l_total_amount
                    where
                        scheduler_id = x_scheduler_id;

                end if;

            end if;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    procedure mass_ins_scheduler_details (
        p_scheduler_id        number,
        p_acc_id              number_tbl,
        p_er_amount           number_tbl,
        p_ee_amount           number_tbl,
        p_er_fee_amount       number_tbl,
        p_ee_fee_amount       number_tbl,
        p_user_id             number,
        x_scheduler_detail_id out number_tbl,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) as
        l_total_amount number := 0;
    begin
        x_return_status := 'S';
        for ind in p_acc_id.first..p_acc_id.last loop
            insert into scheduler_details (
                scheduler_detail_id,
                scheduler_id,
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date
            ) values ( scheduler_detail_seq.nextval,
                       p_scheduler_id,
                       p_acc_id(ind),
                       p_er_amount(ind),
                       p_ee_amount(ind),
                       p_er_fee_amount(ind),
                       p_ee_fee_amount(ind),
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate ) returning scheduler_detail_id into x_scheduler_detail_id ( ind );

        end loop;

        if sql%rowcount > 0 then
            select
                sum(er_amount + ee_amount)
            into l_total_amount
            from
                scheduler_details
            where
                scheduler_id = p_scheduler_id;

            if l_total_amount > 0 then
                update scheduler_master
                set
                    amount = l_total_amount
                where
                    scheduler_id = p_scheduler_id;

            end if;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    procedure ins_scheduler_details (
        p_scheduler_id        number,
        p_acc_id              number,
        p_er_amount           number,
        p_ee_amount           number,
        p_er_fee_amount       number,
        p_ee_fee_amount       number,
        p_user_id             number,
        p_note                varchar2 default null,
        x_scheduler_detail_id out number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is
        l_scheduler_detail_id number;
        l_total_amount        number := 0;
    begin
        x_return_status := 'S';
        update scheduler_details
        set
            er_amount = p_er_amount,
            ee_amount = p_ee_amount,
            er_fee_amount = p_er_fee_amount,
            ee_fee_amount = p_ee_fee_amount,
            note = p_note,
            last_updated_date = sysdate,
            last_updated_by = p_user_id
        where
                scheduler_id = p_scheduler_id
            and acc_id = p_acc_id;

        if sql%rowcount = 0 then
            insert into scheduler_details (
                scheduler_detail_id,
                scheduler_id,
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                note,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date
            ) values ( scheduler_detail_seq.nextval,
                       p_scheduler_id,
                       p_acc_id,
                       p_er_amount,
                       p_ee_amount,
                       p_er_fee_amount,
                       p_ee_fee_amount,
                       p_note,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate ) returning scheduler_detail_id into l_scheduler_detail_id;

            x_scheduler_detail_id := l_scheduler_detail_id;  -- Added by Joshi
        end if;

        if sql%rowcount > 0 then
            select
                sum(er_amount + ee_amount)
            into l_total_amount
            from
                scheduler_details
            where
                scheduler_id = p_scheduler_id;

            if l_total_amount > 0 then
                update scheduler_master
                set
                    amount = l_total_amount
                where
                    scheduler_id = p_scheduler_id;

            end if;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end ins_scheduler_details;

    procedure ins_payroll_transfer (
        p_entrp_id     in number,
        p_amount       in number,
        p_trans_date   in date,
        p_user_id      in number,
        p_plan_type    in varchar2,
        p_check_number in varchar2,
        p_reason_code  in number,
        x_list_bill    out number,
        p_note         in varchar2 default null
    ) as
        l_list_bill number;
    begin
        pc_log.log_error('PC_SCHEDULE', ' Calling ins_payroll_transfer_details payroll ');
        for x in (
            select
                list_bill
            from
                employer_deposits
            where
                check_number = p_check_number
        ) loop
            l_list_bill := x.list_bill;
        end loop;

        pc_log.log_error('PC_SCHEDULE', 'list_bill ' || l_list_bill);
        if l_list_bill is not null then
            update employer_deposits
            set
                check_amount = p_amount,
                posted_balance = p_amount,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    list_bill = l_list_bill
                and check_number = p_check_number;

        else
            select
                employer_deposit_seq.nextval
            into l_list_bill
            from
                dual;

            insert into employer_deposits a (
                employer_deposit_id,
                entrp_id,
                list_bill,
                check_number,
                check_amount,
                check_date,
                posted_balance,
                fee_bucket_balance,
                remaining_balance,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                note,
                plan_type,
                reason_code,
                pay_code
            )
                select
                    l_list_bill -- EMPLOYER_DEPOSIT_ID
                    ,
                    p_entrp_id -- ENTRP_ID
                    ,
                    l_list_bill-- LIST_BILL
                    ,
                    p_check_number-- x.check_number -- CHECK_NUMBER
                    ,
                    p_amount -- CHECK_AMOUNT
                    ,
                    p_trans_date   -- CHECK_DATE
                    ,
                    p_amount   -- POSTED_BALANCE
                    ,
                    0   -- FEE_BUCKET_BALANCE
                    ,
                    0 --x.check_amount -- REMAINING_BALANCE  verfify
                    ,
                    p_user_id -- CREATED_BY
                    ,
                    sysdate   -- CREATION_DATE
                    ,
                    p_user_id -- LAST_UPDATED_BY
                    ,
                    sysdate   -- LAST_UPDATE_DATE
                    ,
                    nvl(p_note, 'Deposit for Recurring schedule')-- NOTE
                    ,
                    p_plan_type,
                    p_reason_code,
                    decode(p_reason_code, 17, 9, 4)
                from
                    dual
                where
                    not exists (
                        select
                            *
                        from
                            employer_deposits
                        where
                                entrp_id = p_entrp_id
                            and check_number = p_check_number
                    );

        end if;

        x_list_bill := l_list_bill;
    end;

    procedure ins_payroll_transfer_details (
        p_acc_id       in number,
        trans_date     in date,
        er_amt         in number,
        ee_amt         in number,
        user_id        in number,
        p_plan_type    in varchar2,
        p_check_number in varchar2,
        p_check_amount in number,
        p_reason_code  in number,
        p_list_bill    in number,
        p_entrp_id     in number,
        p_note         in varchar2 default null
    ) as
    begin
        pc_log.log_error('PC_SCHEDULE', ' Calling ins_payroll_transfer_details payroll ');
        insert into income (
            change_num,
            acc_id,
            fee_date,
            fee_code,
            amount,
            amount_add,
            pay_code,
            cc_number,
            note,
            created_by,
            creation_date,
            last_updated_by,
            last_updated_date,
            transaction_type,
            contributor_amount,
            plan_type,
            list_bill,
            contributor,
            debit_card_posted
        )
            select
                change_seq.nextval -- change_num
                ,
                p_acc_id   -- acc_id
                ,
                trans_date -- fee_date
                ,
                p_reason_code,
                er_amt -- employer deposit
                ,
                ee_amt -- employee deposit
                ,
                decode(p_reason_code, 11, 4, 1) -- pay code ( check ) 1 for testing, vanitha will give the right info
                ,
                p_check_number --x.CHECK_NUMBER -- cc_number
                ,
                nvl(p_note,
                    'generate ' || to_char(sysdate, 'MM/DD/YYYY')),
                user_id -- CREATED_BY
                ,
                sysdate   -- CREATION_DATE
                ,
                user_id -- LAST_UPDATED_BY
                ,
                sysdate,
                'I' -- I - Income, P - Payment
                ,
                p_check_amount,
                p_plan_type,
                p_list_bill,
                p_entrp_id,
                case
                    when p_plan_type in ( 'FSA', 'LPF', 'HRA' )
                         and p_reason_code = 17 then
                        'Y'
                    else
                        'N'
                end
            from
                dual
            where
                not exists (
                    select
                        *
                    from
                        income
                    where
                            acc_id = p_acc_id
                        and cc_number = p_check_number
                );

    end;

    procedure process_schedule (
        p_schedule_id in number,
        p_acc_id      in number default null,
        p_user_id     in number
    ) is

        date_list        schedule_date_table;
        transaction_id   number;
        return_status    varchar2(1);
        error_message    varchar2(300);
        app_exception exception;
        l_acc_id         number;
        l_amount         number := 0;
        l_fee_amount     number := 0;
        l_trans_type     varchar2(1);
        l_xfer_detail_id number;
        l_list_bill      number;
        l_trans_date     date;
        l_count          number := 0;
        l_note           varchar2(200);
        cursor cur_sched is
        select
            scheduler_id,
            s.acc_id                                                    m_acc_id,
            payment_method,
            payment_type,
            reason_code,
            payment_start_date,
            payment_end_date,
            recurring_flag,
            amount,
            fee_amount,
            bank_acct_id,
            contributor,
            plan_type,
            decode(orig_system_source, 'CLAIMN', orig_system_ref, null) claim_id,
            post_prev_pay_period           -- added by jaggi #11365
        from
            scheduler_master s
        where
                trunc(payment_end_date) >= trunc(sysdate)
            and trunc(payment_start_date) <= trunc(sysdate)
            and payment_method = 'PAYROLL'
            and nvl(s.status, 'A') = 'A' -- need to avoid deleted scheduler from processing - PPP Joshi
            and ( p_schedule_id is null
                  or ( p_schedule_id is not null
                       and scheduler_id = p_schedule_id ) )
            and ( acc_id = nvl(p_acc_id, acc_id) );

        cursor cur_details (
            p_scheduler_id  number,
            p_schedule_date date
        ) is
        select
            sd.acc_id             d_acc_id,
            nvl(er_amount, 0)     er_amount,
            nvl(ee_amount, 0)     ee_amount,
            nvl(er_fee_amount, 0) er_fee_amount,
            nvl(ee_fee_amount, 0) ee_fee_amount,
            bp.ben_plan_id,
            sd.scheduler_detail_id,
            bp.effective_end_date,
            bp.effective_date,
            bp.ben_plan_id_main,
            bp.funding_options
        from
            scheduler_details         sd,
            ben_plan_enrollment_setup bp,
            scheduler_master          sm
        where
                sd.scheduler_id = p_scheduler_id
            and sd.acc_id = bp.acc_id
            and sm.plan_type = bp.plan_type
            and sd.scheduler_id = sm.scheduler_id
            and bp.status in ( 'I', 'A' )
            and trunc(bp.effective_date) <= trunc(p_schedule_date)
            and trunc(bp.effective_date) <= trunc(sysdate)
            and bp.plan_end_date >= trunc(sysdate)
            and ( er_amount > 0
                  or ee_amount > 0 )
            and trunc(nvl(bp.effective_end_date, sysdate)) >= trunc(sysdate)
                 -- after shavee confirms we should have this in place
               --AND PC_FIN.contribution_YTD(bp.ACC_ID,bp.PRODUCT_TYPE,bp.PLAN_TYPE,bp.PLAN_START_DATE,bp.PLAN_END_DATE)
                                      --    < bp.annual_election
            and sd.status = 'A';

        -- Added by Joshi for 11365. defined new cursor for non recuring as we are allowing termincated employees to be included in the
        -- scheduler.
        cursor cur_detail_nonrec (
            p_scheduler_id  number,
            p_schedule_date date
        ) is
        select
            sd.acc_id             d_acc_id,
            nvl(er_amount, 0)     er_amount,
            nvl(ee_amount, 0)     ee_amount,
            nvl(er_fee_amount, 0) er_fee_amount,
            nvl(ee_fee_amount, 0) ee_fee_amount,
            bp.ben_plan_id,
            sd.scheduler_detail_id,
            bp.effective_end_date,
            bp.effective_date,
            bp.ben_plan_id_main,
            bp.funding_options
        from
            scheduler_details         sd,
            ben_plan_enrollment_setup bp,
            scheduler_master          sm
        where
                sd.scheduler_id = p_scheduler_id
            and sd.acc_id = bp.acc_id
            and sm.plan_type = bp.plan_type
            and sd.scheduler_id = sm.scheduler_id
            and bp.status in ( 'I', 'A' )
            and trunc(bp.effective_date) <= trunc(p_schedule_date)
            and trunc(bp.effective_date) <= trunc(sysdate)
            and p_schedule_date between plan_start_date and plan_end_date
            and bp.plan_end_date >= trunc(sysdate)
            and ( er_amount > 0
                  or ee_amount > 0 )
            and sd.status = 'A';

    begin
        for x in cur_sched loop
            begin
                date_list.delete;
                if x.reason_code = 17 then
                    if p_schedule_id is not null then
                        process_rollover(x.scheduler_id, x.m_acc_id, p_user_id);
                    end if;

                else
                    if
                        x.recurring_flag = 'Y'
                        and p_schedule_id is not null
                    then
                        for xx in (
                            select
                                period_date
                            from
                                scheduler_calendar
                            where
                                    schedule_id = x.scheduler_id
                                and trunc(period_date) <= trunc(sysdate)
                        )
--                          AND ((NVL(x.post_prev_pay_period,'N') = 'Y' AND TRUNC(period_date) <= TRUNC(sysdate)) OR (NVL(x.post_prev_pay_period,'N') = 'N' AND TRUNC(period_date) = TRUNC(sysdate)))) -- Added by Jaggi #11365
                         loop
                            date_list(date_list.count) := xx.period_date;
                        end loop;
                    elsif
                        x.recurring_flag = 'Y'
                        and p_schedule_id is null
                    then

           /* FOR xx IN ( SELECT period_date
                         FROM scheduler_calendar
                        WHERE schedule_id = X.scheduler_id
                         -- AND TRUNC(PERIOD_DATE) =  TRUNC(SYSDATE)
                          AND ((NVL(x.post_prev_pay_period,'N') = 'Y' AND TRUNC(period_date) <= TRUNC(sysdate)) OR (NVL(x.post_prev_pay_period,'N') = 'N'
                          AND TRUNC(period_date) = TRUNC(sysdate)))
                     --     AND NOT EXISTS (SELECT * FROM EMPLOYER_DEPOSITS WHERE check_number =  X.scheduler_id || to_char(period_date, 'MMDDYYYY'))

                          ) -- Added by Jaggi #11365
           LOOP */
           -- Commented above and added below code by Joshi for 11588
                        for xx in (
                            select
                                sc.period_date
                            from
                                scheduler_calendar sc,
                                scheduler_master   sm
                            where
                                    sm.scheduler_id = sc.schedule_id
                                and sc.schedule_id = x.scheduler_id
                                and ( ( nvl(x.post_prev_pay_period, 'N') = 'Y'
                                        and trunc(period_date) <= trunc(sysdate) )
                                      or ( nvl(x.post_prev_pay_period, 'N') = 'N'
                                           and trunc(period_date) = trunc(sysdate) ) )
                                and not exists (
                                    select
                                        *
                                    from
                                        employer_deposits
                                    where
                                            entrp_id = sm.contributor
                                        and check_number = x.scheduler_id
                                                           || to_char(period_date, 'MMDDYYYY')
                                )
                        ) loop
                            date_list(date_list.count) := xx.period_date;
                        end loop;
                    else
                        date_list(1) := x.payment_start_date;
                    end if;

                    if date_list.count > 0 then
                        pc_log.log_error('PC_SCHEDULE', ' payment start date ' || x.payment_start_date);
                        pc_log.log_error('PC_SCHEDULE', ' date_list.count ' || date_list.count);
                        pc_log.log_error('PC_SCHEDULE', ' m_acc_id ' || x.m_acc_id);
                        for ind in date_list.first..date_list.last loop
                            if x.payment_method = 'ACH' then
                                if ( x.payment_type = 'D' )
                                or (
                                    x.payment_type = 'C'
                                    and x.contributor is null
                                ) then --ee_amt * scheduler amt is the same
                                    if
                                        x.plan_type is not null
                                        and x.claim_id is not null
                                    then
                                        pc_ach_transfer.ins_ach_transfer_hrafsa(x.m_acc_id,
                                                                                x.bank_acct_id,
                                                                                x.payment_type,
                                                                                x.amount,
                                                                                x.fee_amount,
                                                                                date_list(ind),
                                                                                x.reason_code,
                                                                                2,
                                                                                p_user_id,
                                                                                x.claim_id,
                                                                                x.plan_type,
                                                                                3,
                                                                                transaction_id,
                                                                                return_status,
                                                                                error_message);
                                    else
                                        pc_ach_transfer.ins_ach_transfer(x.m_acc_id,
                                                                         x.bank_acct_id,
                                                                         x.payment_type,
                                                                         x.amount,
                                                                         x.fee_amount,
                                                                         date_list(ind),
                                                                         x.reason_code,
                                                                         2,
                                                                         p_user_id,
                                                                         3,
                                                                         transaction_id,
                                                                         return_status,
                                                                         error_message);
                                    end if;

                                    if return_status != 'S' then
                                        raise app_exception;
                                    end if;
                                elsif
                                    x.payment_type = 'C'
                                    and x.contributor is not null
                                then
                                    if
                                        x.plan_type is not null
                                        and x.claim_id is not null
                                    then
                                        pc_ach_transfer.ins_ach_transfer_hrafsa(x.m_acc_id,
                                                                                x.bank_acct_id,
                                                                                x.payment_type,
                                                                                x.amount,
                                                                                x.fee_amount,
                                                                                date_list(ind),
                                                                                x.reason_code,
                                                                                2,
                                                                                p_user_id,
                                                                                x.claim_id,
                                                                                x.plan_type,
                                                                                3,
                                                                                transaction_id,
                                                                                return_status,
                                                                                error_message);
                                    else
                                        pc_ach_transfer.ins_ach_transfer(x.m_acc_id,
                                                                         x.bank_acct_id,
                                                                         x.payment_type,
                                                                         x.amount,
                                                                         x.fee_amount,
                                                                         date_list(ind),
                                                                         x.reason_code,
                                                                         2,
                                                                         p_user_id,
                                                                         3,
                                                                         transaction_id,
                                                                         return_status,
                                                                         error_message);
                                    end if;

                                    if return_status != 'S' then
                                        raise app_exception;
                                    end if;
                                    for det in cur_details(x.scheduler_id,
                                                           date_list(ind)) loop
                                        dbms_output.put_line(det.d_acc_id);
                                        if nvl(det.ee_amount, 0) + nvl(det.er_amount, 0) + nvl(det.ee_fee_amount, 0) + nvl(det.er_fee_amount
                                        , 0) > 0 then
                                            insert into ach_transfer_details (
                                                xfer_detail_id,
                                                transaction_id,
                                                group_acc_id,
                                                acc_id,
                                                ee_amount,
                                                er_amount,
                                                ee_fee_amount,
                                                er_fee_amount,
                                                last_updated_by,
                                                created_by,
                                                last_update_date,
                                                creation_date
                                            ) values ( ach_transfer_details_seq.nextval,
                                                       transaction_id,
                                                       x.m_acc_id,
                                                       det.d_acc_id,
                                                       det.ee_amount,
                                                       det.er_amount,
                                                       det.ee_fee_amount,
                                                       det.er_fee_amount,
                                                       p_user_id,
                                                       p_user_id,
                                                       sysdate,
                                                       sysdate );

                                        end if;

                                        if return_status != 'S' then
                                            raise app_exception;
                                        end if;
                                    end loop;

                                end if;

                            elsif x.payment_method = 'PAYROLL' then -- payment method payroll

                                select
                                    count(*)
                                into l_count
                                from
                                    scheduler_details
                                where
                                    scheduler_id = x.scheduler_id;

                                pc_log.log_error('PC_SCHEDULE',
                                                 'scheduler id '
                                                 || x.scheduler_id
                                                 || ' date list '
                                                 || trunc(date_list(ind)));

                                l_amount := 0;
                                l_fee_amount := 0;
                                if nvl(x.recurring_flag, 'N') = 'N' then
                                    for xy in (
                                        select
                                            sum(nvl(er_amount, 0) + nvl(ee_amount, 0))         amount,
                                            sum(nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) fee_amount
                                        from
                                            scheduler_details sd,
                                            scheduler_master  sm
                                        where
                                                sm.scheduler_id = x.scheduler_id
                                            and sm.scheduler_id = sd.scheduler_id
                                            and nvl(sm.recurring_flag, 'N') = 'N'
                                            and ( er_amount > 0
                                                  or ee_amount > 0 )
                                            and sd.status = 'A'
                                    ) loop
                                        l_amount := xy.amount;
                                        l_fee_amount := xy.fee_amount;
                                    end loop;

                                    if
                                        l_count > 0
                                        and ( nvl(l_amount, 0) > 0
                                        or nvl(l_fee_amount, 0) > 0 )
                                    then
                                        l_note := 'Deposit for Non Recurring schedule';
                                        ins_payroll_transfer(x.contributor,
                                                             l_amount,
                                                             date_list(ind),
                                                             p_user_id,
                                                             x.plan_type,
                                                             x.scheduler_id
                                                             || to_char(
                                            date_list(ind),
                                            'MMDDYYYY'
                                        ),
                                                             x.reason_code,
                                                             l_list_bill,
                                                             l_note);

                                        for det in cur_detail_nonrec(x.scheduler_id,
                                                                     date_list(ind)) loop
                                            pc_log.log_error('PC_SCHEDULE', ' det.d_acc_id ' || det.d_acc_id);
                                            if nvl(det.ee_amount, 0) + nvl(det.er_amount, 0) > 0 then
                                                ins_payroll_transfer_details(
                                                    p_acc_id       => det.d_acc_id,
                                                    trans_date     => date_list(ind),
                                                    er_amt         => det.er_amount,
                                                    ee_amt         => det.ee_amount,
                                                    user_id        => p_user_id,
                                                    p_plan_type    => x.plan_type,
                                                    p_check_number => x.scheduler_id
                                                                      || to_char(
                                                        date_list(ind),
                                                        'MMDDYYYY'
                                                    ),
                                                    p_check_amount => l_amount,
                                                    p_reason_code  => x.reason_code,
                                                    p_list_bill    => l_list_bill,
                                                    p_entrp_id     => x.contributor
                                                );

                                            end if;

                                            if
                                                x.reason_code = 11
                                                and x.plan_type is not null
                                            then
                                                for xxx in (
                                                    select
                                                        *
                                                    from
                                                        ben_plan_enrollment_setup
                                                    where
                                                            ben_plan_id = det.ben_plan_id_main
                                                        and funding_options = 'PUF'
                                              --AND PC_FIN.contribution_YTD(bp.ACC_ID,bp.PRODUCT_TYPE,bp.PLAN_TYPE,bp.PLAN_START_DATE,bp.PLAN_END_DATE)
                                              --    < bp.annual_election
                                                ) loop
                                                    insert_payroll_cont_invoice(
                                                        p_acc_id              => det.d_acc_id,
                                                        p_payroll_date        => date_list(ind),
                                                        p_amount              => nvl(det.ee_amount, 0) + nvl(det.er_amount, 0),
                                                        p_plan_type           => x.plan_type,
                                                        p_entrp_id            => x.contributor,
                                                        p_scheduler_id        => x.scheduler_id,
                                                        p_scheduler_detail_id => det.scheduler_detail_id,
                                                        p_user_id             => p_user_id
                                                    );
                                                end loop;
                                            end if;

                                            if trunc(det.effective_end_date) = trunc(sysdate) then
                                                update scheduler_details
                                                set
                                                    status = 'I',
                                                    last_updated_date = sysdate,
                                                    last_updated_by = p_user_id
                                                where
                                                    scheduler_detail_id = det.scheduler_detail_id;

                                            end if;

                                        end loop;

                                        reconcile_employer_deposit(l_list_bill);
                                    end if;

                                else
                                    for xy in (
                                        select
                                            sum(nvl(er_amount, 0) + nvl(ee_amount, 0))         amount,
                                            sum(nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) fee_amount
                                        from
                                            scheduler_details         sd,
                                            ben_plan_enrollment_setup bp,
                                            scheduler_master          sm
                                        where
                                                sm.scheduler_id = x.scheduler_id
                                            and sm.scheduler_id = sd.scheduler_id
                                            and sd.acc_id = bp.acc_id
                                            and bp.status not in ( 'R', 'P' )
                                            and nvl(sm.recurring_flag, 'N') = 'Y'
                                            and trunc(bp.effective_date) <= trunc(date_list(ind))
                                            and ( er_amount > 0
                                                  or ee_amount > 0 )
                                            and trunc(nvl(bp.effective_end_date, sysdate)) >= trunc(sysdate)
                                            and sd.status = 'A'
                                    ) loop
                                        l_amount := xy.amount;
                                        l_fee_amount := xy.fee_amount;
                                    end loop;

                                    if
                                        l_count > 0
                                        and ( nvl(l_amount, 0) > 0
                                        or nvl(l_fee_amount, 0) > 0 )
                                    then
                                        l_note := 'Deposit for Recurring schedule';
                                        ins_payroll_transfer(x.contributor,
                                                             l_amount,
                                                             date_list(ind),
                                                             p_user_id,
                                                             x.plan_type,
                                                             x.scheduler_id
                                                             || to_char(
                                            date_list(ind),
                                            'MMDDYYYY'
                                        ),
                                                             x.reason_code,
                                                             l_list_bill,
                                                             l_note);

                                        for det in cur_details(x.scheduler_id,
                                                               date_list(ind)) loop
                                            pc_log.log_error('PC_SCHEDULE', ' det.d_acc_id ' || det.d_acc_id);
                                            if nvl(det.ee_amount, 0) + nvl(det.er_amount, 0) > 0 then
                                                ins_payroll_transfer_details(
                                                    p_acc_id       => det.d_acc_id,
                                                    trans_date     => date_list(ind),
                                                    er_amt         => det.er_amount,
                                                    ee_amt         => det.ee_amount,
                                                    user_id        => p_user_id,
                                                    p_plan_type    => x.plan_type,
                                                    p_check_number => x.scheduler_id
                                                                      || to_char(
                                                        date_list(ind),
                                                        'MMDDYYYY'
                                                    ),
                                                    p_check_amount => l_amount,
                                                    p_reason_code  => x.reason_code,
                                                    p_list_bill    => l_list_bill,
                                                    p_entrp_id     => x.contributor
                                                );

                                            end if;

                                            if
                                                x.reason_code = 11
                                                and x.plan_type is not null
                                            then
                                                for xxx in (
                                                    select
                                                        *
                                                    from
                                                        ben_plan_enrollment_setup
                                                    where
                                                            ben_plan_id = det.ben_plan_id_main
                                                        and funding_options = 'PUF'
                                          --AND PC_FIN.contribution_YTD(bp.ACC_ID,bp.PRODUCT_TYPE,bp.PLAN_TYPE,bp.PLAN_START_DATE,bp.PLAN_END_DATE)
                                          --    < bp.annual_election
                                                ) loop
                                                    insert_payroll_cont_invoice(
                                                        p_acc_id              => det.d_acc_id,
                                                        p_payroll_date        => date_list(ind),
                                                        p_amount              => nvl(det.ee_amount, 0) + nvl(det.er_amount, 0),
                                                        p_plan_type           => x.plan_type,
                                                        p_entrp_id            => x.contributor,
                                                        p_scheduler_id        => x.scheduler_id,
                                                        p_scheduler_detail_id => det.scheduler_detail_id,
                                                        p_user_id             => p_user_id
                                                    );
                                                end loop;
                                            end if;

                                            if trunc(det.effective_end_date) = trunc(sysdate) then
                                                update scheduler_details
                                                set
                                                    status = 'I',
                                                    last_updated_date = sysdate,
                                                    last_updated_by = p_user_id
                                                where
                                                    scheduler_detail_id = det.scheduler_detail_id;

                                            end if;

                                        end loop;

                                        reconcile_employer_deposit(l_list_bill);
                                    end if;

                                end if;   -- recurring flag

                 -- Added by Joshi for PPP.change status to P once schedule is processed for non recurring.
                                if x.recurring_flag = 'N' then
                                    update scheduler_master
                                    set
                                        status = 'P'
                                    where
                                        scheduler_id = x.scheduler_id;
                    -- Generate payroll invoice as soon as it is processed
                   -- PC_INVOICE.run_payroll_invoice(X.payment_start_date, X.CONTRIBUTOR);
                                end if;

                            end if;  -- Payment method
                        end loop; --date list
                    end if;

                end if;

            exception
                when app_exception then
                    pc_log.log_error('process_schedule ', error_message);
                when others then
                    pc_log.log_error('process_schedule:When others ', sqlerrm);
            end;
        end loop;  --scheduler
        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20041, 'Scheduling process failed. ' || sqlerrm);
    end;
   /* else--recurring flag N
      if (upper(x.payment_method)='ACH'   ) then
               if  (upper(x.payment_type)='DISBURSEMENT' )
                                or(upper(x.payment_type)='CONTRIBUTION' and x.contributor is null)   then
                    pc_ach_transfer.ins_ach_transfer(x.m_acc_id, x.bank_acct_id,
                                                 case upper(x.payment_type)
                                                      when 'CONTRIBUTION' then 'C'
                                                      else 'D' end ,
                                                  x.amount,x.fee_amount, x.payment_start_date, x.reason_code,
                                                  null, -- status , 4 for disburse, 5 for pay cont
                                                  p_user_id, transaction_id,return_status, error_message);
                    if return_status != 'S' then
                       raise app_exception;
                    end if;

               elsif  upper(x.payment_type)='CONTRIBUTION' and x.contributor is not null then
                    pc_ach_transfer.ins_ach_transfer(x.m_acc_id, x.bank_acct_id,'C',
                                                  x.amount, x.fee_amount,x.payment_start_date, x.reason_code,
                                                  null, -- status , 4 for disburse, 5 for pay cont
                                                  p_user_id, transaction_id,return_status, error_message);
                    if return_status != 'S' then
                       raise app_exception;
                    end if;
                    for det in cur_details(x.scheduler_id)
                       loop
                        pc_ach_transfer_details.insert_ach_transfer_details(transaction_id,x.contributor,det.d_acc_id,
                                                  det.ee_amount,det.er_amount,det.ee_fee_amount,det.er_fee_amount,
                                                  p_user_id,l_xfer_detail_id,return_status, error_message);

                       if return_status != 'S' then
                           raise app_exception;
                        end if;
                       end loop;
               end if;



            else-- payment method payroll
              --insert into income table
              null;
            end if;

    end if;--recurring flag
    */
    procedure update_scheduler (
        p_scheduler_id        in number,
        p_payment_method      varchar2,
        p_payment_type        varchar2,
        p_reason_code         number,
        p_payment_start_date  date,
        p_payment_end_date    date,
        p_recurring_flag      varchar2,
        p_recurring_frequency varchar2,
        p_amount              number,
        p_fee_amount          number,
        p_bank_acct_id        number,
        p_plan_type           varchar2,
        p_pay_to_all          varchar2,
        p_pay_to_all_amount   number,
        p_note                varchar2,
        p_user_id             number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is
        l_scheduler_id        number;
        l_period_date_changed varchar2(1) := 'N';
    begin
        delete from scheduler_calendar
        where
            schedule_id = p_scheduler_id;

        if
            p_recurring_flag = 'Y'
            and p_recurring_frequency is not null
            and p_payment_end_date is not null
            and p_payment_start_date is not null
        then
            pc_schedule.generate_calendar(
                p_schedule_id => p_scheduler_id,
                p_frequency   => p_recurring_frequency,
                p_start_date  => p_payment_start_date,
                p_end_date    => p_payment_end_date,
                p_user_id     => p_user_id
            );

		 -- Added by Joshi for Ticket 7504 : Regenerating the scheduler if scheduler calendar is changed.
            for x in (
                select
                    payment_start_date,
                    payment_end_date,
                    contributor,
                    recurring_frequency
                from
                    scheduler_master
                where
                    scheduler_id = p_scheduler_id
            ) loop
                if ( x.payment_start_date <> p_payment_start_date )
                or ( x.payment_end_date <> p_payment_end_date ) then
                    for y in (
                        select
                            calendar_id
                        from
                            calendar_master
                        where
                                entrp_id = x.contributor
                            and calendar_type = 'PAYROLL_CALENDAR'
                    ) loop
                        if y.calendar_id is not null then
                            begin
                                select
                                    s.scheduler_id
                                into l_scheduler_id
                                from
                                    scheduler_master s
                                where
                                        s.calendar_id = y.calendar_id
                                    and s.payment_start_date = x.payment_start_date
                                    and s.payment_end_date = x.payment_end_date
                                    and s.recurring_frequency = x.recurring_frequency;

                            exception
                                when no_data_found then
                                    l_scheduler_id := null;
                            end;

                            if l_scheduler_id is not null then
                                delete from scheduler_master
                                where
                                    scheduler_id = l_scheduler_id;

                                delete from scheduler_calendar
                                where
                                    schedule_id = l_scheduler_id;

                                l_period_date_changed := 'Y';
                                pc_log.log_error('UPDATE_scheduler', '- deleted scheduler  ' || l_scheduler_id);
                            end if;

                        end if;
                    end loop;

                end if;
            end loop;
         -- code ends here Joshi
        end if;

        update scheduler_master
        set
            payment_method = p_payment_method,
            payment_type = p_payment_type,
            reason_code = p_reason_code,
            payment_start_date = p_payment_start_date,
            payment_end_date = p_payment_end_date,
            recurring_flag = p_recurring_flag,
            recurring_frequency = p_recurring_frequency,
            amount = p_amount,
            fee_amount = p_fee_amount,
            bank_acct_id = p_bank_acct_id,
            plan_type = p_plan_type,
            pay_to_all = p_pay_to_all,
            pay_to_all_amount = p_pay_to_all_amount,
            note = p_note
        where
            scheduler_id = p_scheduler_id;

   --Ticket 7504 Joshi : recreate calendar as start date or end date is changed.
        if l_period_date_changed = 'Y' then
            pc_schedule.copy_pay_calendar(p_scheduler_id);
        end if;
    end update_scheduler;

    procedure import_scheduler_details (
        p_scheduler_id  in number,
        p_user_id       in number,
        p_batch_number  in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) as

        l_entrp_id         number := null;
        l_plan_type        varchar2(30) := null;
        l_ben_plan_main_id number := null;
        l_acc_id           number;
        app_exception exception;
        l_error_msg        varchar2(100);
        l_total_amount     number;
        l_batch_number     number;
        l_sch_det_id       number;
    begin
        x_return_status := 'S';
        select
            contributor,
            plan_type
        into
            l_entrp_id,
            l_plan_type
        from
            scheduler_master
        where
            scheduler_id = p_scheduler_id;

  --dbms_output.put_line('ben_plan_id '||l_ben_plan_main_id);
        insert into scheduler_details_stg (
            sch_det_stg_id,
            acc_num,
            ssn,
            er_amount,
            ee_amount,
            er_fee_amount,
            ee_fee_amount,
            batch_number,
            scheduler_id,
            created_by,
            creation_date,
            last_updated_by,
            last_updated_date,
            status,
            note
        )
            select
                scheduler_details_stg_seq.nextval,
                acc_num,
                ssn,
                employer_amount,
                employee_amount,
                employer_fee,
                employee_fee,
                p_batch_number,
                p_scheduler_id,
                p_user_id,
                sysdate,
                p_user_id,
                sysdate,
                'U',
                note
            from
                scheduler_external;


  --dbms_output.put_line('ben_plan_id '||l_ben_plan_main_id);

  -- if ssn is given
        for x in (
            select
                b.acc_id,
                sum(nvl(a.er_amount, 0))     employer_amount,
                sum(nvl(a.ee_amount, 0))     employee_amount,
                sum(nvl(a.er_fee_amount, 0)) employer_fee,
                sum(nvl(a.ee_fee_amount, 0)) employee_fee,
                a.ssn,
                a.note
            from
                scheduler_details_stg a,
                account               b,
                person                c,
                scheduler_master      d
            where
                    b.pers_id = c.pers_id
                and a.scheduler_id = d.scheduler_id
                and c.ssn = format_ssn(a.ssn)
                and d.contributor = c.entrp_id
                and d.scheduler_id = p_scheduler_id
            group by
                b.acc_id,
                a.ssn,
                a.note
            order by
                b.acc_id
        )
  --for x in(select * from scheduler_external_test)
         loop
            insert into scheduler_details (
                scheduler_detail_id,
                scheduler_id,
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date,
                note
            ) values ( scheduler_detail_seq.nextval,
                       p_scheduler_id,
                       x.acc_id,
                       nvl(x.employer_amount, 0),
                       nvl(x.employee_amount, 0),
                       nvl(x.employer_fee, 0),
                       nvl(x.employee_fee, 0),
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       x.note ) returning scheduler_detail_id into l_sch_det_id;

            update scheduler_details_stg
            set
                scheduler_detail_id = l_sch_det_id,
                acc_id = x.acc_id,
                status = 'P',
                last_updated_date = sysdate,
                last_updated_by = p_user_id
            where
                    batch_number = p_batch_number
                and status = 'U'
                and ssn = x.ssn;

        end loop;

  -- for the ones with account number supplied
        for x in (
            select
                b.acc_id,
                sum(nvl(a.er_amount, 0))     employer_amount,
                sum(nvl(a.ee_amount, 0))     employee_amount,
                sum(nvl(a.er_fee_amount, 0)) employer_fee,
                sum(nvl(a.ee_fee_amount, 0)) employee_fee,
                a.acc_num,
                a.note
            from
                scheduler_details_stg a,
                account               b,
                scheduler_master      d
            where
                    a.scheduler_id = d.scheduler_id
                and b.acc_num = a.acc_num
                and d.scheduler_id = p_scheduler_id
            group by
                b.acc_id,
                a.acc_num,
                a.note
            order by
                b.acc_id
        )
  --for x in(select * from scheduler_external_test)
         loop
            insert into scheduler_details (
                scheduler_detail_id,
                scheduler_id,
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date,
                note
            ) values ( scheduler_detail_seq.nextval,
                       p_scheduler_id,
                       x.acc_id,
                       nvl(x.employer_amount, 0),
                       nvl(x.employee_amount, 0),
                       nvl(x.employer_fee, 0),
                       nvl(x.employee_fee, 0),
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       x.note ) returning scheduler_detail_id into l_sch_det_id;

            update scheduler_details_stg
            set
                scheduler_detail_id = l_sch_det_id,
                acc_id = x.acc_id,
                status = 'P',
                last_updated_date = sysdate,
                last_updated_by = p_user_id
            where
                    batch_number = p_batch_number
                and status = 'U'
                and acc_num = x.acc_num;

        end loop;

        update scheduler_details_stg
        set
            error_message = 'Cannot Find Account, Scheduler is not setup for this account ',
            status = 'E',
            last_updated_date = sysdate
        where
                status = 'U'
            and batch_number = p_batch_number;

        if sql%rowcount > 0 then
            select
                sum(er_amount + ee_amount)
            into l_total_amount
            from
                scheduler_details
            where
                scheduler_id = p_scheduler_id;

            if l_total_amount > 0 then
                update scheduler_master
                set
                    amount = l_total_amount
                where
                    scheduler_id = p_scheduler_id;

            end if;

        end if;

        commit;
    exception
        when app_exception then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_msg;
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end import_scheduler_details;

    procedure export_scheduler_detail_file (
        pv_file_name in varchar2,
        p_user_id    in number
    ) as

        l_file       utl_file.file_type;
        l_buffer     raw(32767);
        l_amount     binary_integer := 32767;
        l_pos        integer := 1;
        l_blob       blob;
        l_blob_len   integer;
        exc_no_file exception;
        l_create_ddl varchar2(32000);
        lv_dest_file varchar2(300);
        lv_create exception;
        l_sqlerrm    varchar2(32000);
        l_create_error exception;
        l_row_count  number := -1;
    begin
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
      --pc_log.log_error(' export scheduler detail ','lv_dest_file '||lv_dest_file);
      /* Get the contents of BLOB from wwv_flow_files */
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        l_file := utl_file.fopen('DEBIT_DIR', lv_dest_file, 'w', 32767);
        l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
      -- Open / Creates the destination file.
        while l_pos < l_blob_len loop
            dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
            utl_file.put_raw(l_file, l_buffer, true);
            l_pos := l_pos + l_amount;
        end loop;

        utl_file.fclose(l_file);
        delete from wwv_flow_files
        where
            name = pv_file_name;

        begin
            for x in (
                select
                    count(*) cnt
                from
                    scheduler_external
            ) loop
                l_row_count := x.cnt;
            end loop;
        exception
            when others then
                null;
        end;

   --  IF l_row_count = 0 THEN
    --    RAISE lv_create;
  --   END IF;

        begin
            execute immediate '
                   ALTER TABLE scheduler_external
                    location (DEBIT_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of Scheduler Detail file' || sqlerrm;
                raise l_create_error;
        end;

    exception
        when lv_create then
            rollback;
            raise_application_error('-20001', 'Scheduler Detail file seems to be corrupted, Use correct template');
        when others then
            rollback;
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_scheduler_detail_file;

    procedure upload_scheduler_details (
        p_file_name     in varchar2,
        p_scheduler_id  in number,
        p_batch_number  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) as
    begin
        x_return_status := 'S';
        export_scheduler_detail_file(p_file_name, p_user_id);
        import_scheduler_details(p_scheduler_id, p_user_id, p_batch_number, x_return_status, x_error_message);
    end;

    procedure reconcile_employer_deposit (
        p_list_bill in number
    ) is
    begin
        for x in (
            select
                a.entrp_id,
                check_date,
                sum(nvl(b.amount, 0) + nvl(b.amount_add, 0)) check_amount,
                b.list_bill,
                b.plan_type,
                posted_balance,
                remaining_balance
            from
                employer_deposits a,
                income            b
            where
                    a.list_bill = p_list_bill
	    -- and   a.reason_code = 11
                and a.list_bill = b.list_bill
                and a.entrp_id = b.contributor
            group by
                a.entrp_id,
                check_date,
                b.list_bill,
                b.plan_type,
                posted_balance,
                remaining_balance
            order by
                check_date desc
        ) loop
            update employer_deposits
            set
                check_amount = x.check_amount,
                posted_balance = x.check_amount,
                remaining_balance = 0
            where
                    list_bill = x.list_bill
                and entrp_id = x.entrp_id;

        end loop;
    end reconcile_employer_deposit;

    function get_scheduler_id (
        p_entrp_id        in number,
        p_acc_id          in number,
        p_plan_type       in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return number is
        l_scheduler_id number;
        l_cnt          number := 0;
    begin
        for x in (
            select
                scheduler_id
            from
                scheduler_master
            where
                    recurring_flag = 'Y'
                and acc_id = nvl(p_acc_id, acc_id)
                and contributor = nvl(p_entrp_id, contributor)
                and plan_type = p_plan_type
                and trunc(payment_start_date) >= trunc(p_plan_start_date)
                and trunc(payment_end_date) <= trunc(p_plan_end_date)
        ) loop
            l_scheduler_id := x.scheduler_id;
            l_cnt := l_cnt + 1;
        end loop;

        if l_cnt = 1 then
            return l_scheduler_id;
        else
            return null;
        end if;
    end get_scheduler_id;

    procedure inactivate_scheduler (
        p_acc_id         in number,
        p_effective_date in date
    ) is
    begin
        update scheduler_details
        set
            status = 'I',
            last_updated_date = sysdate
        where
            acc_id = p_acc_id;

    end inactivate_scheduler;

    procedure update_transit_parking_sch (
        p_scheduler_id        number,
        p_acc_id              number,
        p_er_amount           number,
        p_ee_amount           number,
        p_er_fee_amount       number,
        p_ee_fee_amount       number,
        p_user_id             number,
        p_note                varchar2 default null,
        p_scheduler_detail_id in number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is
        l_plan_type varchar(30);
    begin
        x_return_status := 'S';
        pc_log.log_error('update_transit_parking_sch', 'p_scheduler_detail_id ' || p_scheduler_detail_id);
        for x in (
            select
                plan_type
            from
                scheduler_master
            where
                scheduler_id = p_scheduler_id
        ) loop
            l_plan_type := x.plan_type;
        end loop;

        if p_scheduler_detail_id is not null then
            if nvl(p_er_amount, 0) + nvl(p_ee_amount, 0) + nvl(p_er_fee_amount, 0) + nvl(p_ee_fee_amount, 0) = 0 then
                if l_plan_type in ( 'TRN', 'PKG' ) then
                    update scheduler_details
                    set
                        er_amount = p_er_amount,
                        ee_amount = p_ee_amount,
                        er_fee_amount = p_er_fee_amount,
                        ee_fee_amount = p_ee_fee_amount,
                        note = p_note
                    where
                            scheduler_detail_id = p_scheduler_detail_id
                        and acc_id = p_acc_id;

                else
                    x_return_status := 'E';
                    x_error_message := 'Payroll contribution cannot be zero for plan types other than transit and parking';
                    pc_log.log_error('update_transit_parking_sch', 'x_error_message ' || x_error_message);
                end if;

            end if;
        end if;

    end update_transit_parking_sch;

    procedure process_ach_schedule (
        p_schedule_id in number,
        p_acc_id      in number default null,
        p_user_id     in number
    ) is

        date_list        schedule_date_table;
        l_transaction_id number;
        return_status    varchar2(1);
        error_message    varchar2(300);
        app_exception exception;
        l_acc_id         number;
        l_amount         number := 0;
        l_fee_amount     number := 0;
        l_trans_type     varchar2(1);
        l_xfer_detail_id number;
        l_list_bill      number;
        l_trans_date     date;
        l_count          number := 0;
        cursor cur_sched is
        select
            scheduler_id,
            m_acc_id,
            payment_method,
            payment_type,
            reason_code,
            payment_start_date,
            payment_end_date,
            recurring_flag,
            amount,
            fee_amount,
            bank_acct_id,
            contributor,
            plan_type,
            recurring_frequency,
            claim_id
        from
            er_bank_draft_schedule_v s
        where
            ( ( recurring_flag = 'N'
                and payment_start_date = trunc(sysdate) )
              or ( recurring_flag = 'Y'
                   and payment_end_date >= trunc(sysdate) ) )
            and ( p_schedule_id is null
                  or ( p_schedule_id is not null
                       and scheduler_id = p_schedule_id ) )
            and ( p_acc_id is null
                  or ( p_acc_id is not null
                       and m_acc_id = p_acc_id ) );

        cursor cur_details (
            p_scheduler_id  number,
            p_schedule_date date
        ) is
        select
            sd.acc_id             d_acc_id,
            nvl(er_amount, 0)     er_amount,
            nvl(ee_amount, 0)     ee_amount,
            nvl(er_fee_amount, 0) er_fee_amount,
            nvl(ee_fee_amount, 0) ee_fee_amount,
            sd.scheduler_detail_id
        from
            scheduler_details sd,
            scheduler_master  sm,
            account           acc
        where
                sd.scheduler_id = p_scheduler_id
            and sm.payment_method = 'ACH'
            and sd.scheduler_id = sm.scheduler_id
            and acc.acc_id = sd.acc_id
            and acc.account_status <> 4
            and nvl(er_amount, 0) + nvl(ee_amount, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) > 0
            and sd.status = 'A';

    begin
        pc_log.log_error('pc_scheduler.process_ach_schedule', 'start p_schedule_id'
                                                              || p_schedule_id
                                                              || 'p_acc_id:'
                                                              || p_acc_id);
  --dbms_output.put_line('process started');
        for x in cur_sched loop
            pc_log.log_error('pc_scheduler.process_ach_schedule', 'loop p_schedule_id'
                                                                  || p_schedule_id
                                                                  || 'p_acc_id:'
                                                                  || p_acc_id);
            date_list.delete;
            if
                x.recurring_flag = 'Y'
                and p_schedule_id is not null
            then
                for xx in (
                    select
                        period_date
                    from
                        scheduler_calendar
                    where
                            schedule_id = x.scheduler_id
                        and trunc(period_date) = trunc(sysdate)
                ) loop
                    date_list(date_list.count) := xx.period_date;
        --dbms_output.put_line('p_scheduler is not null x.scheduler_id: ' || x.scheduler_id || 'x.recurring_flag: ' || x.recurring_flag );
                end loop;
            elsif
                x.recurring_flag = 'Y'
                and p_schedule_id is null
            then
                for xx in (
                    select
                        period_date
                    from
                        scheduler_calendar
                    where
                            schedule_id = x.scheduler_id
                        and trunc(period_date) = trunc(sysdate)
                ) loop
                    date_list(date_list.count) := xx.period_date;
        -- dbms_output.put_line('p_scheduler is null x.scheduler_id: ' || x.scheduler_id || 'x.recurring_flag: ' || x.recurring_flag );

                end loop;
            else
                date_list(1) := x.payment_start_date;
        ---dbms_output.put_line('recurring flag N x.scheduler_id: ' || x.scheduler_id || 'x.recurring_flag: ' || x.recurring_flag );
            end if;

            if date_list.count > 0 then
                for ind in date_list.first..date_list.last loop
                    pc_log.log_error('pc_scheduler.process_ach_schedule',
                                     'x.scheduler_id: '
                                     || x.scheduler_id
                                     || 'date_list(ind):'
                                     || date_list(ind));
       -- dbms_output.put_line('x.scheduler_id: ' || x.scheduler_id ||'date_list(ind):' || date_list(ind) );
                    l_transaction_id := null;
                    if
                        x.payment_method = 'ACH'
                        and x.payment_type = 'C'
                        and x.contributor is not null
                    then
                        l_transaction_id := null;
                        if check_ach_scheduled('BANK_DRAFT',
                                               null,
                                               x.m_acc_id,
                                               date_list(ind),
                                               nvl(x.amount, 0) + nvl(x.fee_amount, 0),
                                               x.payment_type,
                                               x.scheduler_id) = 'N' then
                            if x.plan_type is null then

               /* pc_ach_transfer.ins_ach_transfer(x.m_acc_id, x.bank_acct_id,x.payment_type,
                               x.amount, x.fee_amount,date_list(ind)
                               , x.reason_code,
                               2,p_user_id, 3,l_transaction_id,return_status, error_message);
              */
                                pc_log.log_error('pc_scheduler.process_ach_schedule INSERT INTO ACH_TRANSFER', 'p_user_id: ' || p_user_id
                                );
                                insert into ach_transfer (
                                    transaction_id,
                                    acc_id,
                                    bank_acct_id,
                                    transaction_type,
                                    amount,
                                    fee_amount,
                                    total_amount,
                                    transaction_date,
                                    reason_code,
                                    status,
                                    pay_code,
                                    last_updated_by,
                                    created_by,
                                    last_update_date,
                                    creation_date,
                                    ach_source
                                ) values ( ach_transfer_seq.nextval,
                                           x.m_acc_id,
                                           x.bank_acct_id,
                                           x.payment_type,
                                           x.amount,
                                           x.fee_amount,
                                           nvl(x.amount, 0) + nvl(x.fee_amount, 0),
                                           date_list(ind),
                                           x.reason_code,
                                           2,
                                           5,
                                           p_user_id,
                                           p_user_id,
                                           sysdate,
                                           sysdate,
                                           'ONLINE' ) returning transaction_id into l_transaction_id;

                            end if;

                        end if;

                        if return_status != 'S' then
                            raise app_exception;
                        end if;
                        if l_transaction_id is not null then
           -- dbms_output.put_line('l_transaction_id: ' || l_transaction_id);
                            pc_log.log_error('pc_scheduler.process_ach_schedule', 'l_transaction_id: ' || l_transaction_id);
                            for det in cur_details(x.scheduler_id,
                                                   date_list(ind)) loop
              -- dbms_output.put_line(det.d_acc_id);
                                if nvl(det.ee_amount, 0) + nvl(det.er_amount, 0) + nvl(det.ee_fee_amount, 0) + nvl(det.er_fee_amount,
                                0) > 0 then
                                    insert into ach_transfer_details (
                                        xfer_detail_id,
                                        transaction_id,
                                        group_acc_id,
                                        acc_id,
                                        ee_amount,
                                        er_amount,
                                        ee_fee_amount,
                                        er_fee_amount,
                                        last_updated_by,
                                        created_by,
                                        last_update_date,
                                        creation_date
                                    ) values ( ach_transfer_details_seq.nextval,
                                               l_transaction_id,
                                               x.m_acc_id,
                                               det.d_acc_id,
                                               det.ee_amount,
                                               det.er_amount,
                                               det.ee_fee_amount,
                                               det.er_fee_amount,
                                               p_user_id,
                                               p_user_id,
                                               sysdate,
                                               sysdate );

                                end if;

                                if return_status != 'S' then
                                    raise app_exception;
                                end if;
                            end loop;   -- det

                            if x.recurring_flag = 'N' then
                                update scheduler_master
                                set
                                    status = 'P'
                                where
                                    scheduler_id = x.scheduler_id;

                            end if;

                        end if;

                        for zz in (
                            select
                                sum(nvl(det.ee_amount, 0) + nvl(det.er_amount, 0))                                                         amount
                                ,
                                sum(nvl(det.ee_fee_amount, 0) + nvl(det.er_fee_amount, 0))                                                 fee_amount
                                ,
                                sum(nvl(det.ee_amount, 0) + nvl(det.er_amount, 0) + nvl(det.ee_fee_amount, 0) + nvl(det.er_fee_amount
                                , 0)) total_amount
                            from
                                ach_transfer_details det
                            where
                                transaction_id = l_transaction_id
                            group by
                                transaction_id
                        ) loop
                            update ach_transfer
                            set
                                amount = zz.amount,
                                fee_amount = zz.fee_amount,
                                total_amount = zz.total_amount,
                                scheduler_id = x.scheduler_id
                            where
                                transaction_id = l_transaction_id;

                        end loop;

                    end if; -- payment_method = 'ACH'
                end loop; --date list
            end if; -- date list
        end loop;  --scheduler

 -- commit;
    exception
        when app_exception then
            rollback;
            pc_log.log_error('pc_scheduler.process_ach_schedule APP_EXCEPTION', 'ERROR_MESSAGE: ' || error_message);
            raise_application_error(-20040, error_message);
        when others then
            pc_log.log_error('pc_scheduler.process_ach_schedule OTHERS', 'OTHERS ' || sqlerrm);
            rollback;
            raise_application_error(-20041, 'Scheduling process failed. ' || sqlerrm);
    end process_ach_schedule;

    function get_ach_schedule (
        p_start_dt       in date,
        p_end_dt         in date,
        p_payment_method in varchar2
    ) return date is
        l_date date;
    begin
        if trunc(p_end_dt) >= trunc(sysdate) then
            if p_payment_method = 'MONTHLY' then
                l_date := add_months(p_start_dt,
                                     round(months_between(p_end_dt, p_start_dt)));
            elsif p_payment_method = 'WEEKLY' then
                l_date := add_weeks(p_start_dt,
                                    round((p_end_dt - p_start_dt) / 7));
            elsif p_payment_method = 'BIWEEKLY' then
                l_date := get_biweekly(p_start_dt,
                                       round((p_end_dt - p_start_dt) / 14));
            elsif p_payment_method = 'SEMIMONTHLY' then
                select
                    round(period_date)
                into l_date
                from
                    semi_monthly_v
                where
                        trunc(period_date) >= trunc(p_end_dt)
                    and period_date < sysdate + 15;

            elsif p_payment_method = 'QUARTERLY' then
                l_date :=
                    case
                        when mod(
                            trunc(months_between(p_end_dt, p_start_dt)),
                            3
                        ) = 0 then
                            add_months(p_start_dt,
                                       round(months_between(p_end_dt, p_start_dt)))
                        else p_start_dt
                    end;
            elsif p_payment_method = 'BIANNUALLY' then
                l_date :=
                    case
                        when mod(
                            trunc(months_between(p_end_dt, p_start_dt)),
                            6
                        ) = 0 then
                            add_months(p_start_dt,
                                       round(months_between(p_end_dt, p_start_dt)))
                        else p_start_dt
                    end;
            elsif p_payment_method = 'ANNUALLY' then
                l_date :=
                    case
                        when mod(
                            trunc(months_between(p_end_dt, p_start_dt)),
                            12
                        ) = 0 then
                            add_months(p_start_dt,
                                       round(months_between(p_end_dt, p_start_dt)))
                        else p_start_dt
                    end;
            end if;
        end if;

        return l_date;
    end get_ach_schedule;

    procedure create_rollover (
        p_entrp_id        in number,
        p_ben_plan_id     in number,
        p_acc_id          in number,
        p_amount          in number,
        p_plan_type       in varchar2,
        p_er_name         in varchar2,
        p_user_id         in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) is
        l_scheduler_id  number;
        l_scheduler_id2 number;
        l_scheduler_id1 number;
    begin
        for x in (
            select
                p_entrp_id     entrp_id,
                p_amount       amount,
                'CURRENT_YEAR' period
            from
                dual
            union
            select
                p_entrp_id,
                - p_amount,
                'PREVIOUS_YEAR'
            from
                dual
        ) loop
    -- Net out the balance for last year
            insert into scheduler_master (
                scheduler_id,
                acc_id,
                scheduler_name,
                payment_method,
                payment_type,
                reason_code,
                payment_start_date,
                payment_end_date,
                recurring_flag,
                amount,
                contributor,
                plan_type,
                note,
                orig_system_source,
                orig_system_ref,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date
            ) values ( scheduler_seq.nextval,
                       p_acc_id,
                       'Rollover for '
                       || p_er_name
                       || ' '
                       || p_plan_type
                       || ' '
                       || to_char(p_plan_start_date, 'mm/dd/yyyy')
                       || '-'
                       || to_char(p_plan_end_date, 'mm/dd/yyyy'),
                       'PAYROLL',
                       'C',
                       17, -- Rollover reason
                       case
                           when x.period = 'PREVIOUS_YEAR' then
                               p_plan_end_date
                           else
                               sysdate
                       end,
                       sysdate,
                       'N',
                       x.amount,
                       p_entrp_id,
                       p_plan_type,
                       'Rollover schedule created on ' || to_char(sysdate, 'MM/DD/YYYY'),
                       'ROLLOVER',
                       p_ben_plan_id,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate ) returning scheduler_id into l_scheduler_id;

            pc_log.log_error('CREATE_ROLLOVER', 'scheduled ' || l_scheduler_id);
            if l_scheduler_id1 is null then
                l_scheduler_id1 := l_scheduler_id;
            else
                l_scheduler_id2 := l_scheduler_id;
            end if;

        end loop;

        for y in (
            select
                a.acc_id
            from
                fsa_hra_employees_v a,
                ben_plan_coverages  b
            where
                    a.entrp_id = p_entrp_id
                and a.ben_plan_id = b.ben_plan_id
                and ( a.termination_date is null
                      or a.termination_date > sysdate )
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            c.acc_id = a.acc_id
                        and plan_end_date > sysdate
                        and status <> 'P'
                        and c.plan_type in ( 'FSA', 'LPF' )
                )
                and a.acc_id not in (
                    select
                        b.acc_id
                    from
                        scheduler_master  a, scheduler_details b
                    where
                            a.scheduler_id = b.scheduler_id
                        and a.orig_system_ref = p_ben_plan_id
                ) --Added to remove duplicate processing
                and a.ben_plan_id_main = p_ben_plan_id
                and decode(max_rollover_amount,
                           0,
                           acc_balance,
                           least(max_rollover_amount, acc_balance)) > 0
                and a.plan_type in ( 'FSA', 'LPF' )
            union
            select
                a.acc_id
            from
                fsa_hra_employees_v a,
                ben_plan_coverages  b
            where
                    a.entrp_id = p_entrp_id
                and a.ben_plan_id = b.ben_plan_id
                and ( a.termination_date is null
                      or a.termination_date > sysdate )
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup c
                    where
                            c.acc_id = a.acc_id
                        and plan_end_date > sysdate
                        and status <> 'P'
                        and a.product_type = c.product_type
                )
                and a.acc_id not in (
                    select
                        b.acc_id
                    from
                        scheduler_master  a, scheduler_details b
                    where
                            a.scheduler_id = b.scheduler_id
                        and a.orig_system_ref = p_ben_plan_id
                ) --Added to remove duplicate processing
                and a.ben_plan_id_main = p_ben_plan_id
                and decode(max_rollover_amount,
                           0,
                           acc_balance,
                           least(max_rollover_amount, acc_balance)) > 0
                and a.product_type = 'HRA'
        ) loop
            for x in (
                select
                    p_entrp_id      entrp_id,
                    p_amount        amount,
                    'CURRENT_YEAR'  period,
                    l_scheduler_id2 schedule_id
                from
                    dual
                union
                select
                    p_entrp_id,
                    - p_amount,
                    'PREVIOUS_YEAR',
                    l_scheduler_id1 schedule_id
                from
                    dual
            ) loop
                insert into scheduler_details (
                    scheduler_detail_id,
                    scheduler_id,
                    acc_id,
                    er_amount,
                    ee_amount,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_updated_date
                )
                    select
                        scheduler_detail_seq.nextval,
                        x.schedule_id  -- Rollover changes
                        ,
                        a.acc_id,
                        decode(x.period,
                               'PREVIOUS_YEAR',
                               -decode(max_rollover_amount,
                                       0,
                                       acc_balance,
                                       least(max_rollover_amount, acc_balance)),
                               decode(max_rollover_amount,
                                      0,
                                      acc_balance,
                                      least(max_rollover_amount, acc_balance))),
                        0,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        sysdate
                    from
                        fsa_hra_employees_v a,
                        ben_plan_coverages  b
                    where
                            a.entrp_id = p_entrp_id
                        and a.ben_plan_id = b.ben_plan_id
                        and a.acc_id = y.acc_id  ---Another change for rolloevr
                        and ( a.termination_date is null
                              or a.termination_date > sysdate )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup c
                            where
                                    c.acc_id = a.acc_id
                                and plan_end_date > sysdate
                                and status not in ( 'R', 'P' )
                                and a.product_type = c.product_type
                        )
                        and a.ben_plan_id_main = p_ben_plan_id
                        and decode(max_rollover_amount,
                                   0,
                                   acc_balance,
                                   least(max_rollover_amount, acc_balance)) > 0
                        and a.product_type = 'HRA';

                insert into scheduler_details (
                    scheduler_detail_id,
                    scheduler_id,
                    acc_id
               --For Rollover ee amount shud be populated and er amount shud be zero(so ER amount is zero)-Ticket #3863
                    ,
                    ee_amount,
                    er_amount,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_updated_date
                )
                    select
                        scheduler_detail_seq.nextval,
                        x.schedule_id  -- Rollover changes
                        ,
                        a.acc_id,
                        decode(x.period,
                               'PREVIOUS_YEAR',
                               -decode(max_rollover_amount,
                                       0,
                                       acc_balance,
                                       least(max_rollover_amount, acc_balance)),
                               decode(max_rollover_amount,
                                      0,
                                      acc_balance,
                                      least(max_rollover_amount, acc_balance))),
                        0,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        sysdate
                    from
                        fsa_hra_employees_v a,
                        ben_plan_coverages  b
                    where
                            a.entrp_id = p_entrp_id
                        and a.ben_plan_id = b.ben_plan_id
                        and a.acc_id = y.acc_id  ---Another change for rolloevr
                        and ( a.termination_date is null
                              or a.termination_date > sysdate )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup c
                            where
                                    c.acc_id = a.acc_id
                                and plan_end_date > sysdate
                                and status not in ( 'R', 'P' )
                                and c.plan_type in ( 'FSA', 'LPF' )
                        )
                        and a.ben_plan_id_main = p_ben_plan_id
                        and decode(max_rollover_amount,
                                   0,
                                   acc_balance,
                                   least(max_rollover_amount, acc_balance)) > 0
                        and a.plan_type in ( 'FSA', 'LPF' );

            end loop; --Close of X loop
        end loop; --Close of y loop

        pc_log.log_error('CREATE_ROLLOVER', 'scheduled detail ' || sql%rowcount);
    end create_rollover;

    procedure process_rollover (
        p_schedule_id in number,
        p_acc_id      in number default null,
        p_user_id     in number
    ) is

        date_list        schedule_date_table;
        transaction_id   number;
        return_status    varchar2(1);
        error_message    varchar2(300);
        app_exception exception;
        l_acc_id         number;
        l_amount         number := 0;
        l_fee_amount     number := 0;
        l_trans_type     varchar2(1);
        l_xfer_detail_id number;
        l_list_bill      number;
        l_ann_list_bill  number;
        l_trans_date     date;
        l_count          number := 0;
        l_rollover_count number := 0;
        cursor cur_sched is
        select
            scheduler_id,
            s.acc_id                                                    m_acc_id,
            payment_method,
            payment_type,
            reason_code,
            payment_start_date,
            payment_end_date,
            recurring_flag,
            amount,
            fee_amount,
            bank_acct_id,
            contributor,
            plan_type,
            decode(orig_system_source, 'CLAIMN', orig_system_ref, null) claim_id
        from
            scheduler_master s
        where
                payment_method = 'PAYROLL'
            and reason_code = 17
            and scheduler_id = p_schedule_id;

        cursor cur_details (
            p_scheduler_id number
        ) is
        select
            sd.acc_id             d_acc_id,
            nvl(er_amount, 0)     er_amount,
            nvl(ee_amount, 0)     ee_amount,
            nvl(er_fee_amount, 0) er_fee_amount,
            nvl(ee_fee_amount, 0) ee_fee_amount,
            sd.scheduler_detail_id,
            sm.plan_type
        from
            scheduler_details sd,
            scheduler_master  sm
        where
                sd.scheduler_id = p_scheduler_id
            and sd.scheduler_id = sm.scheduler_id
            and reason_code = 17
            and sd.status = 'A';

    begin
        for x in cur_sched loop
            select
                count(*)
            into l_rollover_count
            from
                income                    a,
                ben_plan_enrollment_setup bp
            where
                    a.contributor = x.contributor
                and a.fee_code = 17
                and a.acc_id = bp.acc_id
                and a.plan_type = bp.plan_type
                and a.plan_type = x.plan_type
                and a.cc_number like p_schedule_id
                || '%'
                   and a.fee_date between bp.plan_start_date and bp.plan_end_date;

            if l_rollover_count > 0 then
                error_message := 'Rollover Processed Already ';
                raise app_exception;
            end if;
            ins_payroll_transfer(x.contributor,
                                 x.amount,
                                 x.payment_start_date,
                                 p_user_id,
                                 x.plan_type,
                                 x.scheduler_id
                                 || to_char(x.payment_start_date, 'MMDDYYYY'),
                                 x.reason_code,
                                 l_list_bill);

            if x.plan_type in ( 'HRA', 'FSA', 'LPF' ) then
                ins_payroll_transfer(x.contributor,
                                     x.amount,
                                     x.payment_start_date,
                                     p_user_id,
                                     x.plan_type,
                                     'AE:'
                                     || x.scheduler_id
                                     || ':'
                                     || to_char(x.payment_start_date, 'MMDDYYYY'),
                                     12,
                                     l_ann_list_bill,
                                     'Annual election increase because of rollover ');
            end if;

            for det in cur_details(x.scheduler_id) loop
                pc_log.log_error('PC_SCHEDULE', ' det.d_acc_id ' || det.d_acc_id);
                ins_payroll_transfer_details(
                    p_acc_id       => det.d_acc_id,
                    trans_date     => x.payment_start_date,
                    er_amt         => det.er_amount,
                    ee_amt         => det.ee_amount,
                    user_id        => p_user_id,
                    p_plan_type    => x.plan_type,
                    p_check_number => x.scheduler_id
                                      || to_char(x.payment_start_date, 'MMDDYYYY'),
                    p_check_amount => x.amount,
                    p_reason_code  => x.reason_code,
                    p_list_bill    => l_list_bill,
                    p_entrp_id     => x.contributor
                );

                if x.plan_type in ( 'HRA', 'FSA', 'LPF' ) then
                    ins_payroll_transfer_details(
                        p_acc_id       => det.d_acc_id,
                        trans_date     => x.payment_start_date,
                        er_amt         => det.er_amount,
                        ee_amt         => det.ee_amount,
                        user_id        => p_user_id,
                        p_plan_type    => x.plan_type,
                        p_check_number => 'AE:'
                                          || x.scheduler_id
                                          || ':'
                                          || to_char(x.payment_start_date, 'MMDDYYYY'),
                        p_check_amount => x.amount,
                        p_reason_code  => 12,
                        p_list_bill    => l_ann_list_bill,
                        p_entrp_id     => x.contributor,
                        p_note         => 'Annual election increase because of rollover '
                    );

                    reconcile_employer_deposit(l_ann_list_bill);
                    if nvl(det.er_amount, 0) + nvl(det.ee_amount, 0) < 0 then
                        update ben_plan_enrollment_setup
                        set
                            annual_election = nvl(annual_election, 0) + nvl(det.er_amount, 0) + nvl(det.ee_amount, 0)
                        where
                                acc_id = det.d_acc_id
                            and plan_type in ( 'HRA', 'FSA', 'LPF' )
                            and plan_type = x.plan_type
                            and plan_end_date = x.payment_start_date;

                    else
                        update ben_plan_enrollment_setup
                        set
                            annual_election = nvl(annual_election, 0) + nvl(det.er_amount, 0) + nvl(det.ee_amount, 0)
                        where
                                acc_id = det.d_acc_id
                            and plan_type in ( 'HRA', 'FSA', 'LPF' )
                            and plan_type = x.plan_type
                      /*AND    plan_start_date >= X.payment_START_date*/
                            and plan_end_date > x.payment_start_date;

    -------  Ticket #8683  Added for  FSA rollover notification email by rprabu 13/04/2020
                        if nvl(det.er_amount, 0) + nvl(det.ee_amount, 0) > 0 then
                            pc_notifications.notify_rollover(det.d_acc_id,
                                                             nvl(det.er_amount, 0) + nvl(det.ee_amount, 0),
                                                             x.plan_type);

                        end if;

                    end if;

                end if;

            end loop;

            reconcile_employer_deposit(l_list_bill);
        end loop; --DATE LIST
        commit;
    exception
        when app_exception then
            rollback;
            raise_application_error(-20040, error_message);
        when others then
            rollback;
            raise_application_error(-20041, 'Scheduling process failed. ' || sqlerrm);
    end process_rollover;

    function check_ach_scheduled (
        p_source           in varchar2,
        p_source_id        in number,
        p_acc_id           in number,
        p_transaction_date in date,
        p_amount           in number,
        p_transaction_type in varchar2,
        p_scheduler_id     in number
    ) return varchar2 is
        l_flag varchar2(1) := 'N';
    begin
        if p_source = 'CLAIM' then
            for x in (
                select
                    count(*) cnt
                from
                    ach_transfer
                where
                        acc_id = p_acc_id
                    and claim_id = p_source_id
                    and trunc(transaction_date) = trunc(p_transaction_date)
                    and total_amount = p_amount
                    and transaction_type = p_transaction_type
            ) loop
                if x.cnt > 0 then
                    l_flag := 'Y';
                end if;
            end loop;
        elsif p_source = 'INVOICE' then
            for x in (
                select
                    count(*) cnt
                from
                    ach_transfer
                where
                        acc_id = p_acc_id
                    and invoice_id = to_char(p_source_id)
                    and trunc(transaction_date) = trunc(p_transaction_date)
                    and total_amount = p_amount
                    and transaction_type = p_transaction_type
            ) loop
                if x.cnt > 0 then
                    l_flag := 'Y';
                end if;
            end loop;
        else
            for x in (
                select
                    count(*) cnt
                from
                    ach_transfer
                where
                        acc_id = p_acc_id
                    and trunc(transaction_date) = trunc(p_transaction_date)
                    and total_amount = p_amount
                    and transaction_type = p_transaction_type
                    and scheduler_id = p_scheduler_id
            ) loop
                if x.cnt > 0 then
                    l_flag := 'Y';
                end if;
            end loop;
        end if;

        return nvl(l_flag, 'N');
    end check_ach_scheduled;

    procedure alter_file (
        p_file_name in varchar2
    ) is
        l_create_ddl varchar2(32000);
    begin
        if file_exists(p_file_name, 'LISTBILL_DIR') = 'TRUE' then
            l_create_ddl := 'CREATE TABLE  "HT_LIST_BILL_EXTERNAL"
            (
               "LINE_NUMBER" VARCHAR2(3200 BYTE)
            )
            ORGANIZATION EXTERNAL
            (
              TYPE ORACLE_LOADER DEFAULT DIRECTORY "LISTBILL_DIR"
              ACCESS PARAMETERS ( records delimited BY newline
                badfile '''
                            || p_file_name
                            || '.bad'' logfile '''
                            || p_file_name
                            || '.log''
                fields terminated BY '','' optionally enclosed BY ''"''
              LRTRIM MISSING FIELD VALUES ARE NULL ) LOCATION ( '''
                            || p_file_name
                            || ''' )
            )
            REJECT LIMIT 1';

            begin
                execute immediate 'DROP TABLE HT_LIST_BILL_EXTERNAL';
            exception
                when others then
                    null;
            end;
            pc_log.log_error('create_ddl', l_create_ddl);
            begin
                execute immediate l_create_ddl;
            end;
            if file_exists(p_file_name || '.bad', 'LISTBILL_DIR') = 'TRUE' then
                mail_utility.email_files(
                    from_name    => 'httelecom_listbill@sterlingadministration.com',
                    to_names     => 'techsupport@sterlingadministration.com',
                    subject      => 'Hawaiian Telecom Rejected File',
                    html_message => 'Hawaiian Telecom Rejected File',
                    attach       => samfiles('/u01/app/oracle/oradata/listbill/'
                                       || p_file_name
                                       || '.bad')
                );
            end if;

            if file_exists(p_file_name || '.log', 'LISTBILL_DIR') = 'TRUE' then
                mail_utility.email_files(
                    from_name    => 'httelecom_listbill@sterlingadministration.com',
                    to_names     => 'techsupport@sterlingadministration.com',
                    subject      => 'Hawaiian Telecom Log File',
                    html_message => 'Hawaiian Telecom Log File',
                    attach       => samfiles('/u01/app/oracle/oradata/listbill/'
                                       || p_file_name
                                       || '.log')
                );
            end if;

            transform_file(p_file_name);
        end if;
    end alter_file;

    procedure transform_file (
        p_file_name in varchar2
    ) is

        l_utl_id        utl_file.file_type;
        l_outfile_name  varchar2(255);
        l_line          varchar2(3200);
        l_line_count    number := 0;
        l_col_tbl       gen_xl_xml.varchar2_tbl;
        l_col_value_tbl gen_xl_xml.varchar2_tbl;
        i               number := 0;
    begin
        l_outfile_name := 'TRANSFORMED'
                          || p_file_name
                          || to_char(sysdate, 'HHMMSS')
                          || '.xls';

        l_line := 'Account number, SSN, Employer Amount, Employee Amount, Employer Fee, Employee Fee,Note, Plan Type, Payroll Date,Employee ID,'
        ;
        l_col_tbl(1) := 'Account number';
        l_col_tbl(2) := 'SSN';
        l_col_tbl(3) := 'Employer Amount';
        l_col_tbl(4) := 'Employee Amount';
        l_col_tbl(5) := 'Employer Fee';
        l_col_tbl(6) := 'Employee Fee';
        l_col_tbl(7) := 'Note';
        l_col_tbl(8) := 'Plan Type';
        l_col_tbl(9) := 'Payroll Date';
        l_col_tbl(10) := 'Employee ID';

    /*From: Wendy Suyetsugu [mailto:Wendy.Suyetsugu@hawaiiantel.com]
      Sent: Wednesday, October 16, 2013 1:12 PM
      To: Mark Fukuhara; Sarah Soman
      Cc: Leina Chow; Jeff Furumura; Sheri Braunthal
      Subject: RE: FSA Requests/Questions and Follow-Up Info

      Hi Mark,

      Attached is a sample file and below is the layout.

      The format looks like:
      Length             Position            Information
          20                 1 - 20                Employee Number (ID)
           1                  21 - 21             Account Type
      1 = Dependent care (DCFSA),
      2 = Health (HCFSA)
      6 = Bus Pass (BUSFSA)
      7 = Parking (PKGFSA) and
      8 = Van Pool (VANFSA)
           8                 22 - 29               Deduction Date  YYYYMMDD
           8                 30 - 37              Deduction Amount

      Thanks!
      Wendy

      Wendy.Suyetsugu@Hawaiiantel.com
      Human Resources - HRIS  Sales Compensation
      Office: 808/546-4409
      Mobile: 808/286-7379
      Fax: 808/546-6194
      */
        for x in (
            select
                substr(line_number, 1, 20)       employee_id,
                decode(
                    substr(line_number, 21, 1),
                    '1',
                    'DCA',
                    '2',
                    'FSA',
                    '6',
                    'TRN',
                    '8',
                    'TRN',
                    '7',
                    'PKG'
                )                                plan_type,
                trim(substr(line_number, 22, 8)) deduction_date,
                trim(substr(line_number, 30, 8)) amount
            from
                ht_list_bill_external a
        ) loop
            l_line := null;
            for xx in (
                select
                    a.ssn,
                    b.acc_num
                from
                    person  a,
                    account b
                where
                        a.entrp_id = 11881
                    and a.pers_id = b.pers_id
                    and a.orig_sys_vendor_ref = trim(x.employee_id)
            ) loop
                i := i + 1;
                l_line := xx.acc_num
                          || ','
                          || xx.ssn;
                l_col_value_tbl(i) := xx.acc_num;
                i := i + 1;
                l_col_value_tbl(i) := xx.ssn;
            end loop;

            if l_line is null then
                i := i + 1;
                l_col_value_tbl(i) := null;
                i := i + 1;
                l_col_value_tbl(i) := null;
            end if;

            i := i + 1;
            l_col_value_tbl(i) := x.amount;
            i := i + 1;
            l_col_value_tbl(i) := 0;
            i := i + 1;
            l_col_value_tbl(i) := 0;
            i := i + 1;
            l_col_value_tbl(i) := 0;
            i := i + 1;
            l_col_value_tbl(i) := null;
            i := i + 1;
            l_col_value_tbl(i) := x.plan_type;
            i := i + 1;
            l_col_value_tbl(i) := to_char(to_date(x.deduction_date, 'YYYYMMDD'), 'MM/DD/YYYY');

            i := i + 1;
            l_col_value_tbl(i) := x.employee_id;
        end loop;

        pc_notifications.insert_reports('Hawaiian Telecom Transformed Scheduler Contribution File', '/u01/app/oracle/oradata/listbill/'
        , l_outfile_name, null, 'Hawaiian Telecom Transformed Scheduler Contribution File');
        mail_utility.send_file(
            p_from_email    => 'httelecom_listbill@sterlingadministration.com',
            p_to_email      => 'techsupport@sterlingadministration.com,sarah.soman@sterlingadministration.com,clientservices@sterlingadministration.com,lori.lewis@sterlingadministration.com,anne.dewitt@sterlingadministration.com'
            ,
            p_file_name     => l_outfile_name,
            p_directory     => 'LISTBILL_DIR',
            p_dir_path      => '/u01/app/oracle/oradata/listbill/',
            p_html_message  => 'Hawaiian Telecom Transformed Scheduler Contribution File',
            p_report_title  => 'Hawaiian Telecom Transformed Scheduler Contribution File',
            p_col_tbl       => l_col_tbl,
            p_col_value_tbl => l_col_value_tbl
        );

    exception
        when others then
            raise;
    end transform_file;

    procedure generate_pay_calendar (
        p_frequency  in varchar2,
        p_start_date in date,
        p_end_date   in date,
        p_entrp_id   in number,
        p_user_id    in number
    ) is

        l_trans_date_list    pc_schedule.schedule_date_table;
        l_trans_dt           date;
        l_cnt                number := 0;
        l_period_list        pc_schedule.schedule_date_table;
        l_count              number := 0;
        l_calendar_master_id number;
        l_scheduler_id       number;
        l_schedule_count     number := 0;
    begin
        if p_frequency = 'WEEKLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 52
            )
            select
                period_date
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(p_start_date, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'BIWEEKLY' then
            with data as (
                select
                    2 * level k
                from
                    dual
                connect by
                    level <= 26
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(
                            decode(
                                to_char(p_start_date, 'D'),
                                6,
                                p_start_date,
                                p_start_date +(6 - to_number(to_char(p_start_date, 'D')))
                            ),
                            k
                        ) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'SEMIMONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(trunc(p_start_date, 'MM') + 14,
                                   k) period_date
                    from
                        data
                    union
                    select
                        add_months(
                            last_day(p_start_date),
                            k
                        ) period_date
                    from
                        data
                    where
                        add_months(
                            last_day(p_start_date),
                            k
                        ) > p_start_date
                    order by
                        1
                )
            where
                    period_date >= p_start_date
                and period_date <= p_end_date;

        elsif p_frequency = 'MONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(
                            trunc(p_start_date, 'MM'),
                            k
                        ) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'QUARTERLY' then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(p_start_date, rownum * 3) period_date
                    from
                        all_objects
                    where
                        rownum <= 4
                )
            where
                trunc(period_date) <= trunc(p_end_date);

        elsif p_frequency in ( 'SEMIANNUALLY', 'BIANNUALLY' ) then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        decode(rownum,
                               1,
                               p_start_date,
                               add_months(p_start_date, rownum * 6)) period_date
                    from
                        all_objects
                    where
                        rownum <= 2
                )
            where
                period_date <= p_end_date;

        end if;

        if p_frequency = 'ANNUALLY' then
            l_trans_date_list(l_trans_date_list.count + 1) := p_start_date;
        else
            l_cnt := l_trans_date_list.count;
            if p_frequency in ( 'SEMIWEEKLY', 'BIWEEKLY' ) then
                select
                    decode(
                        to_char(p_start_date, 'D'),
                        6,
                        p_start_date,
                        p_start_date +(6 - to_number(to_char(p_start_date, 'D')))
                    )
                into
                    l_trans_date_list
                (l_trans_date_list.count + 1)
                from
                    dual;

            end if;

            if p_frequency in ( 'QUARTERLY', 'SEMIMONTHLY' ) then
                dbms_output.put_line('l_trans_date_list.COUNT ' || l_trans_date_list.count);
                if p_end_date <> l_trans_date_list(l_trans_date_list.count) then
                    l_trans_date_list(l_trans_date_list.count + 1) := p_end_date;
                end if;

            end if;

        end if;

        if p_entrp_id is not null then
            for x in (
                select
                    calendar_id
                from
                    calendar_master
                where
                        calendar_type = 'PAYROLL_CALENDAR'
                    and entrp_id = p_entrp_id
            ) loop
                l_calendar_master_id := x.calendar_id;
            end loop;
        else
            for x in (
                select
                    calendar_id
                from
                    calendar_master
                where
                        calendar_type = 'PAYROLL_CALENDAR'
                    and entrp_id is null
            ) loop
                l_calendar_master_id := x.calendar_id;
            end loop;
        end if;

        if l_calendar_master_id is null then
            insert into calendar_master values ( calendar_seq.nextval,
                                                 'PAYROLL_CALENDAR',
                                                 p_entrp_id,
                                                 sysdate,
                                                 0,
                                                 sysdate,
                                                 0,
                                                 null ) returning calendar_id into l_calendar_master_id;

        end if;

        if p_entrp_id is null then
            select
                count(*)
            into l_schedule_count
            from
                scheduler_master sm,
                calendar_master  cm
            where
                    cm.calendar_id = sm.calendar_id
                and sm.payment_start_date = p_start_date
                and sm.payment_end_date = p_end_date
                and cm.calendar_type = 'PAYROLL_CALENDAR'
                and cm.entrp_id = p_entrp_id;

        else
            select
                count(*)
            into l_schedule_count
            from
                scheduler_master sm,
                calendar_master  cm
            where
                    cm.calendar_id = sm.calendar_id
                and sm.payment_start_date = p_start_date
                and sm.payment_end_date = p_end_date
                and cm.calendar_type = 'PAYROLL_CALENDAR'
                and cm.entrp_id is null;

        end if;

        if l_schedule_count = 0 then
            insert into scheduler_master (
                scheduler_id,
                acc_id,
                payment_start_date,
                payment_end_date,
                recurring_flag,
                recurring_frequency,
                scheduler_name,
                note,
                creation_date,
                created_by,
                last_updated_date,
                last_updated_by,
                calendar_id
            ) values ( scheduler_seq.nextval,
                       pc_entrp.get_acc_id(p_entrp_id),
                       p_start_date,
                       p_end_date,
                       'Y',
                       p_frequency,
                       p_frequency
                       || ':'
                       || to_char(p_start_date, 'MM/DD/YYYY')
                       || ':'
                       || to_char(p_end_date, 'MM/DD/YYYY'),
                       p_frequency
                       || ':'
                       || to_char(p_start_date, 'MM/DD/YYYY')
                       || ':'
                       || to_char(p_end_date, 'MM/DD/YYYY'),
                       sysdate,
                       0,
                       sysdate,
                       0,
                       l_calendar_master_id ) returning scheduler_id into l_scheduler_id;

            for i in 1..l_trans_date_list.count loop
                insert into scheduler_calendar (
                    scalendar_id,
                    schedule_id,
                    period_date,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( scheduler_calendar_seq.nextval,
                           l_scheduler_id,
                           l_trans_date_list(i),
                           sysdate,
                           0,
                           sysdate,
                           0 );

            end loop;

        end if;

    end;

    procedure copy_pay_calendar (
        p_schedule_id in number
    ) is
        l_calendar_id number;
        l_schedule_id number;
        l_entrp_id    number;
    begin
        for x in (
            select
                b.entrp_id
            from
                scheduler_master a,
                account          b
            where
                    a.acc_id = b.acc_id
                and a.scheduler_id = p_schedule_id
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        for x in (
            select
                calendar_id
            from
                calendar_master
            where
                    entrp_id = l_entrp_id
                and calendar_type = 'PAYROLL_CALENDAR'
        ) loop
            l_calendar_id := x.calendar_id;
        end loop;

        if
            l_calendar_id is null
            and l_entrp_id is not null
        then
            insert into calendar_master values ( calendar_seq.nextval,
                                                 'PAYROLL_CALENDAR',
                                                 l_entrp_id,
                                                 sysdate,
                                                 0,
                                                 sysdate,
                                                 0,
                                                 null ) returning calendar_id into l_calendar_id;

        end if;

        insert into scheduler_master (
            scheduler_id,
            acc_id,
            payment_start_date,
            payment_end_date,
            recurring_flag,
            recurring_frequency,
            scheduler_name,
            note,
            creation_date,
            created_by,
            last_updated_date,
            last_updated_by,
            calendar_id
        )
            select
                scheduler_seq.nextval,
                acc_id,
                payment_start_date,
                payment_end_date,
                'Y',
                recurring_frequency,
                recurring_frequency
                || ':'
                || to_char(payment_start_date, 'MM/DD/YYYY')
                || ':'
                || to_char(payment_end_date, 'MM/DD/YYYY'),
                recurring_frequency
                || ':'
                || to_char(payment_start_date, 'MM/DD/YYYY')
                || ':'
                || to_char(payment_end_date, 'MM/DD/YYYY'),
                sysdate,
                0,
                sysdate,
                0,
                l_calendar_id
            from
                scheduler_master a
            where
                    scheduler_id = p_schedule_id
                and not exists (
                    select
                        *
                    from
                        scheduler_master c
                    where
                            calendar_id = l_calendar_id
                        and a.payment_start_date = c.payment_start_date
                        and a.payment_end_date = c.payment_end_date
                        and a.recurring_frequency = c.recurring_frequency
                );

        if sql%rowcount > 0 then
            insert into scheduler_calendar (
                scalendar_id,
                schedule_id,
                period_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            )
                select
                    scheduler_calendar_seq.nextval,
                    b.scheduler_id,
                    c.period_date,
                    sysdate,
                    0,
                    sysdate,
                    0
                from
                    scheduler_master   a,
                    scheduler_master   b,
                    scheduler_calendar c
                where
                        a.scheduler_id = p_schedule_id
                    and a.scheduler_id = c.schedule_id
                    and b.calendar_id = l_calendar_id
                    and a.acc_id = b.acc_id
                    and a.recurring_frequency = b.recurring_frequency
                    and a.payment_start_date = b.payment_start_date
                    and a.payment_end_date = b.payment_end_date;

        end if;

    end copy_pay_calendar;

    procedure insert_payroll_cont_invoice (
        p_acc_id              in number,
        p_payroll_date        in date,
        p_amount              in number,
        p_plan_type           in varchar2,
        p_entrp_id            in number,
        p_scheduler_id        in number,
        p_scheduler_detail_id in number,
        p_user_id             in number
    ) is
    begin
        insert into payroll_contribution (
            payroll_contribution_id,
            acc_id,
            payroll_date,
            payroll_amount,
            plan_type,
            entrp_id,
            scheduler_id,
            scheduler_detail_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                payroll_contribution_seq.nextval,
                p_acc_id,
                p_payroll_date,
                p_amount,
                p_plan_type,
                p_entrp_id,
                p_scheduler_id,
                p_scheduler_detail_id,
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
                        payroll_contribution
                    where
                            acc_id = p_acc_id
                        and payroll_date = p_payroll_date
                        and scheduler_detail_id = p_scheduler_detail_id
                );

    end insert_payroll_cont_invoice;

    procedure create_generic_calendar as
    begin
        if to_char(sysdate, 'MM/DD') = '02/01' then
            for x in (
                select
                    lookup_code
                from
                    payroll_frequency
                where
                    lookup_code in ( 'SEMIWEEKLY', 'BIWEEKLY', 'SEMIMONTHLY', 'QUARTERLY', 'MONTHLY',
                                     'WEEKLY', 'ANNUALLY', 'SEMIANNUALLY', 'BIANNUALLY' )
            ) loop
                pc_schedule.generate_pay_calendar(
                    p_frequency  => x.lookup_code,
                    p_start_date => '01-JAN-'
                                    || to_char(to_number(to_char(sysdate, 'YYYY')) + 1),
                    p_end_date   => '31-DEC-'
                                  || to_char(to_number(to_char(sysdate, 'YYYY')) + 1),
                    p_entrp_id   => null,
                    p_user_id    => 0
                );
            end loop;

        end if;
    exception
        when others then
            pc_debit_card.insert_alert('Error in Creating Generic Calendar ', sqlerrm);
    end create_generic_calendar;

-- Added for Payroll contribution.
    procedure initialize_scheduler (
        p_batch_number  in number,
        p_scheduler_id  in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_account_type varchar2(30);
    begin
        pc_log.log_error('pc_Scheduler: ', 'Entered initialzer proc');
        x_return_status := 'S';
        pc_log.log_error('initialize_scheduler: - p_batch_number ', p_batch_number);
        pc_log.log_error('initialize_scheduler: - p_scheduler_id ', p_scheduler_id);

  -- Added by Joshi 9382.
        select
            a.account_type
        into l_account_type
        from
            account          a,
            scheduler_master s
        where
                s.acc_id = a.acc_id
            and s.scheduler_id = p_scheduler_id;

        if l_account_type in ( 'HRA', 'FSA' ) then
            for x in (
                select
                    b.acc_id,
                    c.ssn
                from
                    scheduler_details_stg     a,
                    account                   b,
                    person                    c,
                    scheduler_master          d,
                    ben_plan_enrollment_setup bp
                where
                        b.pers_id = c.pers_id
                    and a.scheduler_id = d.scheduler_id
                    and bp.acc_id = b.acc_id
                    and d.plan_type = bp.plan_type
                    and c.ssn = format_ssn(a.ssn)
                    and d.contributor = c.entrp_id
                    and bp.status = 'A'
                    and d.scheduler_id = p_scheduler_id
                    and a.batch_number = p_batch_number
                    and bp.plan_end_date > sysdate
                    and ( bp.effective_end_date is null
                          or bp.effective_end_date > d.payment_start_date )
                group by
                    b.acc_id,
                    c.ssn
                order by
                    b.acc_id
            )
      --for x in(select * from scheduler_external_test)
             loop
                pc_log.log_error('pc_Scheduler: ', 'Entered initialzer ssn loop');
                update scheduler_details_stg
                set
                    acc_id = x.acc_id,
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                        batch_number = p_batch_number
                    and status = 'U'
                    and format_ssn(ssn) = x.ssn;

            end loop;

     -- for the ones with account number supplied
            for x in (
                select
                    b.acc_id,
                    b.acc_num
                from
                    scheduler_details_stg     a,
                    account                   b,
                    scheduler_master          d,
                    ben_plan_enrollment_setup bp
                where
                        a.scheduler_id = d.scheduler_id
                    and bp.acc_id = b.acc_id
                    and b.acc_num = a.acc_num
                    and d.plan_type = bp.plan_type
                    and a.batch_number = p_batch_number
                    and d.scheduler_id = p_scheduler_id
                    and bp.status = 'A'
                    and bp.plan_end_date > sysdate
                    and ( bp.effective_end_date is null
                          or bp.effective_end_date > d.payment_start_date )
            )
        --for x in(select * from scheduler_external_test)
             loop
                pc_log.log_error('pc_Scheduler: ', 'Entered initialzer account loop');
                update scheduler_details_stg
                set
                    acc_id = x.acc_id,
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                        batch_number = p_batch_number
                    and status = 'U'
                    and acc_num = x.acc_num;

            end loop;

        else
     -- for HSA contribution upload.
     -- update acc_id for records SSN entered.
            for x in (
                select
                    b.acc_id,
                    c.ssn
                from
                    scheduler_details_stg a,
                    account               b,
                    person                c,
                    scheduler_master      d
                where
                        b.pers_id = c.pers_id
                    and a.scheduler_id = d.scheduler_id
                    and c.ssn = format_ssn(a.ssn)
                    and d.contributor = c.entrp_id
                 -- AND B.ACCOUNT_STATUS = 1
                    and b.account_status <> 4
                    and nvl(b.signature_on_file, 'N') = 'Y'
                    and d.scheduler_id = p_scheduler_id
                    and a.batch_number = p_batch_number
                group by
                    b.acc_id,
                    c.ssn
                order by
                    b.acc_id
            ) loop
                pc_log.log_error('pc_Scheduler: ', 'Entered initialzer ssn loop');
                update scheduler_details_stg
                set
                    acc_id = x.acc_id,
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                        batch_number = p_batch_number
                    and status = 'U'
                    and format_ssn(ssn) = x.ssn;

            end loop;

    -- update acc_id for records acc_num entered.
            for x in (
                select
                    b.acc_id,
                    b.acc_num
                from
                    scheduler_details_stg a,
                    account               b,
                    scheduler_master      d
                where
                        a.scheduler_id = d.scheduler_id
                    and b.acc_num = a.acc_num
               -- AND b.account_status = 1
                    and b.account_status <> 4
                    and nvl(b.signature_on_file, 'N') = 'Y'
                    and a.batch_number = p_batch_number
                    and d.scheduler_id = p_scheduler_id
            ) loop
                pc_log.log_error('pc_Scheduler: ', 'Entered initialzer ssn loop');
                update scheduler_details_stg
                set
                    acc_id = x.acc_id,
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                        batch_number = p_batch_number
                    and status = 'U'
                    and acc_num = x.acc_num;

            end loop;

        end if;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('validate_scheduler', x_error_message);
    end initialize_scheduler;

    procedure validate_scheduler (
        p_batch_number  in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_setup_error exception;
        l_error_record number;
        l_account_type varchar2(50);
    begin
        x_return_status := 'S';

   -- Added by Joshi for 9382.
        for x in (
            select distinct
                account_type
            from
                scheduler_details_stg sd,
                scheduler_master      s,
                account               a
            where
                    sd.batch_number = p_batch_number
                and sd.scheduler_id = s.scheduler_id
                and s.acc_id = a.acc_id
        ) loop
            l_account_type := x.account_type;
        end loop;

        if l_account_type in ( 'HSA', 'LSA' ) then    -- LSA Added by Swamy for Ticket#9912 on 17/08/2021 (bug 10199)








    -- ACC_ID can not be NULL for and employee.
            update scheduler_details_stg
            set
                error_message = 'Employee is not active',
                status = 'E'
            where
                    batch_number = p_batch_number
                and acc_id is null;

        else
    -- ACC_ID can not be NULL for and employee.
            update scheduler_details_stg
            set
                error_message = 'Employee is not part of plan',
                status = 'E'
            where
                    batch_number = p_batch_number
                and acc_id is null;

        end if;


    -- AND    status = 'U';
   --pc_log.log_error('validate_scheduler - ACC_ID NULL ',  sqlerrmsg);
   /* UPDATE SCHEDULER_DETAILS_STG
    SET    error_message   = 'Enter numeric value for Employer Fee'
          ,status =  'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U'
    AND    IS_NUMBER(ER_AMOUNT) <> 'Y' ;

    UPDATE SCHEDULER_DETAILS_STG
    SET    error_message   =  'Enter numeric value for Employee Fee'
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U'
    AND    IS_NUMBER(EE_AMOUNT) = 'Y' ;

    UPDATE SCHEDULER_DETAILS_STG
    SET    error_message   = CASE WHEN IS_NUMBER(ER_FEE_AMOUNT) = 'Y' THEN NULL ELSE 'Enter numeric value for Employer Fee' END
          ,status = CASE WHEN IS_NUMBER(ER_FEE_AMOUNT) = 'Y' THEN NULL ELSE 'E' END
    WHERE  batch_number = P_batch_number
    AND    status = 'U';

    UPDATE SCHEDULER_DETAILS_STG
    SET    error_message   = CASE WHEN IS_NUMBER(EE_FEE_AMOUNT) = 'Y' THEN NULL ELSE 'Enter numeric value for Employee Fee' END
          ,status = CASE WHEN IS_NUMBER(EE_FEE_AMOUNT) = 'Y' THEN NULL ELSE 'E' END
    WHERE  batch_number = P_batch_number
    AND    status = 'U';

   */

   /*
    UPDATE SCHEDULER_DETAILS_STG
    SET    note   = CASE WHEN  NVL(ER_AMOUNT,0)+NVL(EE_AMOUNT,0)+NVL(ER_FEE_AMOUNT,0)+NVL(EE_FEE_AMOUNT,0) = 0 THEN
                        'Payroll contribution cannot be zero for plan types other than transit and parking'
                    ELSE NULL END
          ,status = CASE WHEN  NVL(ER_AMOUNT,0)+NVL(EE_AMOUNT,0)+NVL(ER_FEE_AMOUNT,0)+NVL(EE_FEE_AMOUNT,0) = 0 THEN
                        'E'
                    ELSE NULL END
    WHERE  batch_number = P_batch_number and plan_type NOT IN ('TRN','PKG','UA1')
    AND    status = 'U';

    UPDATE SCHEDULER_DETAILS_STG
    SET    error_message   = 'Enter valid SSN of employee '
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U' and ssn is null ;

    /* UPDATE SCHEDULER_DETAILS_STG
    SET    note   = 'Enter valid plan type '
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U' and plan_type is null;

    UPDATE SCHEDULER_STAGE
    SET    note   = 'Enter valid plan type '
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U' and not exists ( SELECT * FROM fsa_hra_plan_type where lookup_code = PLAN_TYPE);

    UPDATE SCHEDULER_STAGE
    SET    note   = 'Enter valid frequency'
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U' and not exists ( SELECT * FROM lookups where lookup_name  = 'PAYROLL_FREQUENCY' and meaning = RECURRING_FREQUENCY);

    UPDATE SCHEDULER_STAGE
    SET    note   = 'Cannot derive employee account number '
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U' and ee_acc_id is null;

    UPDATE SCHEDULER_STAGE
    SET    note   = 'Cannot derive employer account number '
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U' and er_acc_id is null;

    UPDATE SCHEDULER_STAGE
    SET    note   = 'Cannot derive employee benefit plan '
          ,status = 'E'
    WHERE  batch_number = P_batch_number
    AND    status = 'U' and ben_plan_id is null;
    */
        select
            count(*)
        into l_error_record
        from
            scheduler_details_stg
        where
                batch_number = p_batch_number
            and status = 'E';

        if l_error_record > 0 then
            raise l_setup_error;
        end if;
    exception
        when l_setup_error then
            x_return_status := 'E';
            pc_log.log_error('validate_scheduler', 'validation error');
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('validate_scheduler', x_error_message);
    end validate_scheduler;

    procedure process_online_scheduler (
        p_batch_number         in number,
        p_scheduler_id         in out number,
        p_plan_type            in varchar2,
        p_acc_id               in number,
        p_acc_num              in varchar2,
        p_contributor          in number,
        p_payment_start_date   in varchar2,
        p_payment_end_date     in varchar2,
        p_recurring_flag       in varchar2,
        p_recurring_frequency  in varchar2,
        p_pay_dates            in pc_online_enrollment.varchar2_tbl,
        p_memo                 in varchar2,
        p_user_id              in number,
        p_bank_acct_id         in number   -- Added by Joshi for 9382
        ,
        p_payment_method       in varchar2 -- Added by Joshi for 9382
        ,
        p_reason_code          in number   -- Added by Joshi for 9382
        ,
        p_post_prev_pay_period in varchar2 -- Added by Jaggi for 10365
        ,
        p_no_of_pay_period     in varchar2 -- Added by Jaggi for 10365
        ,
        x_error_message        out varchar2,
        x_return_status        out varchar2
    ) is

        l_scheduler_id        number;
        l_return_status       varchar2(1);
        l_error_message       varchar2(2000);
        l_setup_error exception;
        l_scheduler_name      varchar2(255);
        l_batch_count         number;
        l_ename               varchar2(15);
        l_plan_end_date       varchar2(20);
        l_schedule_found      integer;
        l_pay_dates           pc_online_enrollment.varchar2_tbl;
        l_period_date_changed varchar2(1);
        l_old_bank_acct_id    number;
        l_acct_type           varchar2(20);
    begin
        x_return_status := 'S';
        l_period_date_changed := 'N';
        l_acct_type := pc_account.get_account_type(p_acc_id);
-- insert into staging table.
        if l_acct_type in ( 'FSA', 'HRA' ) then -- added by jaggi #11365
            select
                count(*)
            into l_batch_count
            from
                scheduler_stage
            where
                    batch_number = p_batch_number
                and plan_type = p_plan_type;

        else
            select
                count(*)
            into l_batch_count
            from
                scheduler_stage
            where
                batch_number = p_batch_number;

        end if;

        pc_log.log_error('pc_Schedule - P_SCHEDULER_ID : ', p_scheduler_id);
        pc_log.log_error('pc_Schedule - P_RECURRING_FREQUENCY : ', p_recurring_frequency);

-- get the plan end date for Transit and praking plans.
--IF P_SCHEDULER_ID IS NULL THEN

        if p_plan_type in ( 'TRN', 'PKG' ) then
            for x in (
                select
                    max(plan_end_date) plan_end_date
                from
                    ben_plan_enrollment_setup plans
                where
                        acc_id = p_acc_id
                    and plan_type not in ( 'TRN', 'PKG' )
          -- ticket 7420.Joshi commented below. payment start date should be between plan start and plan end date.
		  --and TRUNC(plans.plan_start_date) <= TRUNC(SYSDATE) AND TRUNC(plans.plan_end_date) >  TRUNC(SYSDATE))
                    and trunc(to_date(p_payment_start_date, 'mm/dd/yyyy')) between trunc(plans.plan_start_date) and trunc(plans.plan_end_date
                    )
            ) loop
                l_plan_end_date := to_char(x.plan_end_date, 'MM/DD/YYYY');
            end loop;

            if l_plan_end_date is null then
            --l_plan_end_date := '12/31/' || TO_CHAR(SYSDATE,'YYYY'); -- ticket 7420. Joshi need to take year of payment start date.
                l_plan_end_date := '12/31/'
                                   || to_char(to_date(p_payment_start_date, 'MM/DD/YYYY'), 'YYYY');
            end if;

        else
            l_plan_end_date := p_payment_end_date;
        end if;
--END IF;

        if p_recurring_flag = 'N' then
            if trunc(to_date(p_payment_start_date, 'mm/dd/yyyy')) >= trunc(sysdate) then  -- added by jaggi #11487
                l_plan_end_date := to_char(to_date(p_payment_start_date, 'mm/dd/yyyy') + 1, 'MM/DD/YYYY');
            else
                l_plan_end_date := to_char(sysdate, 'mm/dd/yyyy');
            end if;
   --l_plan_end_date := P_PAYMENT_START_DATE;
        end if;

        pc_log.log_error('pc_Schedule - insert scheduler_stage : ',
                         to_char(sysdate, 'mm/dd/yyyy'));
        pc_log.log_error('pc_Schedule - insert scheduler_stage : ', p_payment_start_date);
        pc_log.log_error('pc_Schedule - insert scheduler_stage : ', l_plan_end_date);
        if l_batch_count = 0 then
            insert into scheduler_stage (
                scheduler_stage_id,
                batch_number,
                plan_type,
                er_acc_id,
                entrp_id,
                payment_start_date,
                payment_end_date,
                recurring_flag,
                recurring_frequency,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                note,
                payment_method,
                bank_acct_id,
                post_prev_pay_period,
                no_of_pay_period
            ) -- Added by Jaggi #11365
             values ( scheduler_stage_seq.nextval,
                       p_batch_number,
                       p_plan_type,
                       p_acc_id,
                       p_contributor,
                       to_date(p_payment_start_date, 'MM/DD/YYYY'),
                       to_date(l_plan_end_date, 'MM/DD/YYYY'),
                       p_recurring_flag,
                       p_recurring_frequency,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       p_memo,
                       p_payment_method,
                       p_bank_acct_id,
                       p_post_prev_pay_period,
                       p_no_of_pay_period );

        else
            update scheduler_stage
            set
                plan_type = p_plan_type,
                payment_start_date = to_date(p_payment_start_date, 'MM/DD/YYYY'),
                payment_end_date = to_date(l_plan_end_date, 'MM/DD/YYYY'),
                recurring_flag = p_recurring_flag,
                recurring_frequency = p_recurring_frequency,
                payment_method = p_payment_method,         -- Added by Joshi for 9382
                post_prev_pay_period = p_post_prev_pay_period,   -- Added by Jaggi #11365
                no_of_pay_period = p_no_of_pay_period,       -- Added by Jaggi #11365
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                batch_number = p_batch_number;

        end if;

        pc_log.log_error('pc_Schedule - insert scheduler_stage : ', sqlerrm);
        select
            substr(name, 1, 15)
        into l_ename
        from
            enterprise
        where
            entrp_id = p_contributor;

        l_scheduler_name := to_char(sysdate, 'YYYY')
                            || ' '
                            || p_plan_type
                            || ' '
                            || l_ename;

        if p_scheduler_id is null then
            select
                count(*)
            into l_schedule_found
            from
                scheduler_master
            where
                    plan_type = p_plan_type
                and acc_id = p_acc_id
                and nvl(status, 'A') = 'A'
                and payment_end_date = to_date(l_plan_end_date, 'MM/DD/YYYY')
                and recurring_flag = 'Y'
                and recurring_frequency = p_recurring_frequency
                and ( p_scheduler_id is null
                      or ( p_scheduler_id is not null
                           and scheduler_id <> p_scheduler_id ) );

            if l_schedule_found > 0 then
                l_error_message := 'The Scheduler already exists for the '
                                   || p_plan_type
                                   || ' Plan and Frequency';
                pc_log.log_error('pc_schedule - process_online_scheduler', l_error_message);
                raise l_setup_error;
            end if;

            pc_schedule.ins_scheduler(
                p_acc_id               => p_acc_id,
                p_name                 => l_scheduler_name,
                p_payment_method       => p_payment_method, -- 'PAYROLL', Joshi :9382
                p_payment_type         => 'C',
                p_reason_code          => p_reason_code,       -- 11,  Added by Joshi for 9382
                p_payment_start_date   => to_date(p_payment_start_date, 'MM/DD/YYYY'),
                p_payment_end_date     => to_date(l_plan_end_date, 'MM/DD/YYYY'),
                p_recurring_flag       => p_recurring_flag,
                p_recurring_frequency  => p_recurring_frequency,
                p_amount               => 0,
                p_fee_amount           => 0,
                p_bank_acct_id         => p_bank_acct_id,  -- NULL   ,Joshi :9382
                p_contributor          => p_contributor,
                p_plan_type            => p_plan_type,
                p_orig_system_source   => null,
                p_orig_system_ref      => null,
                p_pay_to_all           => 'N',
                p_pay_to_all_amount    => null,
                p_source               => 'ONLINE',
                p_pay_dates            => p_pay_dates,
                p_user_id              => nvl(p_user_id, 0),
                p_note                 => p_memo,
                p_post_prev_pay_period => p_post_prev_pay_period,  -- Added by Jaggi for 10365
                p_no_of_pay_period     => p_no_of_pay_period,      -- Added by Jaggi for 10365
                x_scheduler_id         => p_scheduler_id,
                x_return_status        => l_return_status,
                x_error_message        => l_error_message
            );

            if x_return_status <> 'S' then
                raise l_setup_error;
            end if;
        else
  -- update the changed pay dates.
            delete from scheduler_calendar
            where
                schedule_id = p_scheduler_id;

	-- Added code by Joshi for Ticket #6031.
  -- if user updates contribution amount/frequency type, scheduler should be updated.

            if
                p_recurring_flag = 'Y'
                and p_recurring_frequency is not null
                and p_payment_end_date is not null
                and p_payment_start_date is not null
            then
                pc_schedule.generate_calendar(
                    p_schedule_id => p_scheduler_id,
                    p_paydates    => p_pay_dates,
                    p_user_id     => p_user_id
                );

         -- Added by Joshi for 9382. The payroll calendar should be created for only HRA/FSA and
         -- not for HSA.
                if p_payment_method = 'PAYROLL' then
                    for x in (
                        select
                            payment_start_date,
                            payment_end_date,
                            contributor,
                            recurring_frequency
                        from
                            scheduler_master
                        where
                            scheduler_id = p_scheduler_id
                    ) loop
                        pc_log.log_error('pc_schedule - process_online_scheduler old scheduler id ', 'in the loop');
                        if ( x.payment_start_date <> to_date ( p_payment_start_date, 'MM/DD/YYYY' ) )
                        or ( x.payment_end_date <> to_date ( p_payment_end_date, 'MM/DD/YYYY' ) )
                        or ( x.recurring_frequency <> p_recurring_frequency ) then
                            for y in (
                                select
                                    calendar_id
                                from
                                    calendar_master
                                where
                                        entrp_id = x.contributor
                                    and calendar_type = 'PAYROLL_CALENDAR'
                            ) loop
                                if y.calendar_id is not null then
                                    begin
                                        select
                                            s.scheduler_id
                                        into l_scheduler_id
                                        from
                                            scheduler_master s
                                        where
                                                s.calendar_id = y.calendar_id
                                            and s.payment_start_date = x.payment_start_date
                                            and s.payment_end_date = x.payment_end_date
                                            and s.recurring_frequency = x.recurring_frequency;

                                    exception
                                        when no_data_found then
                                            l_scheduler_id := null;
                                    end;

                                    if l_scheduler_id is not null then
                                        delete from scheduler_master
                                        where
                                            scheduler_id = l_scheduler_id;

                                        delete from scheduler_calendar
                                        where
                                            schedule_id = l_scheduler_id;

                                        l_period_date_changed := 'Y';
                                    end if;

                                end if;
                            end loop;

                        end if;

                    end loop;

                end if; -- Joshi for 9382.

         -- Added by Joshi 11276
                for b in (
                    select
                        bank_acct_id
                    from
                        scheduler_master
                    where
                        scheduler_id = p_scheduler_id
                ) loop
                    l_old_bank_acct_id := b.bank_acct_id;
                end loop;

                update scheduler_master
                set
                    payment_start_date = to_date(p_payment_start_date, 'mm/dd/yyyy'),
                    payment_end_date = to_date(p_payment_end_date, 'mm/dd/yyyy'),
                    recurring_flag = p_recurring_flag,
                    recurring_frequency = p_recurring_frequency,
                    reason_code = p_reason_code,
                    bank_acct_id = p_bank_acct_id -- Added by Joshi 11276
                    ,
                    note = note || nvl(p_memo, ' '),
                    post_prev_pay_period = p_post_prev_pay_period  -- Added by Jaggi for 10365
                    ,
                    no_of_pay_period = p_no_of_pay_period      -- Added by Jaggi for 10365
                where
                    scheduler_id = p_scheduler_id;

        --Ticket 7504 Joshi : recreate calendar as start date or end date is changed.
        -- commented below and added PAYROLL clause for 9382. Joshi
        --IF l_period_date_changed = 'Y'  AND THEN
                if
                    l_period_date_changed = 'Y'
                    and p_payment_method = 'PAYROLL'
                then
                    pc_schedule.copy_pay_calendar(p_scheduler_id);
                end if;

            end if;

            if p_recurring_flag = 'N' then
                update scheduler_master
                set
                    payment_start_date = to_date(p_payment_start_date, 'MM/DD/YYYY'),
                    payment_end_date = to_date(l_plan_end_date, 'MM/DD/YYYY'),
                    bank_acct_id = p_bank_acct_id  -- Added by Joshi 11276
                    ,
                    reason_code = p_reason_code,
                    note = note || nvl(p_memo, ' '),
                    no_of_pay_period = p_no_of_pay_period      -- Added by Jaggi for 10365
                where
                    scheduler_id = p_scheduler_id;

            end if;

    -- Added by Joshi 11276
            if
                l_old_bank_acct_id <> p_bank_acct_id
                and pc_account.get_account_type(p_acc_id) = 'HSA'
            then
                update ach_transfer
                set
                    bank_acct_id = p_bank_acct_id
                where
                        scheduler_id = p_scheduler_id
                    and status in ( 1, 2 );

            end if;

            if p_scheduler_id > 0 then
        --P_SCHEDULER_ID := P_SCHEDULER_ID;
                update scheduler_stage
                set
                    scheduler_id = p_scheduler_id
                where
                    batch_number = p_batch_number;

            end if;

        end if;

    exception
        when l_setup_error then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_message;
            pc_log.log_error('process_online_scheduler ', l_error_message);
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('process_online_scheduler ', x_error_message);
    end process_online_scheduler;

    procedure insert_online_schd_stg_det (
        p_batch_number  in number,
        p_scheduler_id  in out number,
        p_ee_acc_id     in pc_online_enrollment.varchar2_tbl,
        p_er_amount     in pc_online_enrollment.varchar2_tbl,
        p_ee_amount     in pc_online_enrollment.varchar2_tbl,
        p_er_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_ee_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_ee_acc_id     pc_online_enrollment.varchar2_tbl;
        l_er_amount     pc_online_enrollment.varchar2_tbl;
        l_ee_amount     pc_online_enrollment.varchar2_tbl;
        l_er_fee_amount pc_online_enrollment.varchar2_tbl;
        l_ee_fee_amount pc_online_enrollment.varchar2_tbl;
    begin
        x_return_status := 'S';
        l_ee_acc_id := pc_online_enrollment.array_fill(p_ee_acc_id, p_ee_acc_id.count);
        l_er_amount := pc_online_enrollment.array_fill(p_er_amount, p_er_amount.count);
        l_ee_amount := pc_online_enrollment.array_fill(p_ee_amount, p_ee_amount.count);
-- Added by Joshi for 9382
        l_er_fee_amount := pc_online_enrollment.array_fill(p_er_fee_amount, p_er_amount.count);
        l_ee_fee_amount := pc_online_enrollment.array_fill(p_ee_fee_amount, p_ee_amount.count);

-- delete the existing records and insert everything again.
        delete from scheduler_details_stg
        where
                batch_number = p_batch_number
            and scheduler_id = p_scheduler_id;

        for i in 1..l_ee_acc_id.count loop
            insert into scheduler_details_stg (
                sch_det_stg_id,
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                batch_number,
                scheduler_id,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date,
                status
            ) values ( scheduler_details_stg_seq.nextval,
                       l_ee_acc_id(i),
                       l_er_amount(i),
                       l_ee_amount(i),
                       l_er_fee_amount(i) --  0 Joshi: 9382
                       ,
                       l_ee_fee_amount(i) --  0 Joshi: 9382
                       ,
                       p_batch_number,
                       p_scheduler_id,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       'U' );

        end loop;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('process_scheduler - insert_online_schd_stg_det', x_error_message);
    end insert_online_schd_stg_det;

    function get_employee_schedule (
        p_entrp_id           in number,
        p_scheduler_id       in number,
        p_plan_type          varchar2,
        p_show_term_employee varchar2 default 'N',
        p_plan_start_date    varchar2,
        p_plan_end_date      varchar2
    ) return schedule_detail_t
        pipelined
        deterministic
    is
        l_record schedule_detail_rec;
        l_sql    varchar2(4000);
        type r_cursor is ref cursor;
        c_cur    r_cursor;
    begin
        pc_log.log_error('get_employee_schedule ', 'p_entrp_id :='
                                                   || p_entrp_id
                                                   || ' P_Scheduler_Id :='
                                                   || p_scheduler_id
                                                   || ' p_plan_type :='
                                                   || p_plan_type);

        if p_plan_type is null then
            l_sql := 'SELECT ACCOUNT.ACC_ID
                    ,ACCOUNT.ACC_NUM
                    ,PERSON.FIRST_NAME
                    ,PERSON.LAST_NAME
                    ,NVL(ER_AMOUNT,0)  ER_AMOUNT
                    ,NVL(EE_AMOUNT,0) EE_AMOUNT
                    ,NVL(ER_FEE_AMOUNT,0)  ER_FEE_AMOUNT  -- Added by Joshi for 9382
                    ,NVL(EE_FEE_AMOUNT,0) EE_FEE_AMOUNT
                    ,SCHEDULER_DETAIL_ID
                    ,decode(PC_ACCOUNT.get_status (ACCOUNT.ACC_ID),''Closed'',''Terminated'',PC_ACCOUNT.get_status (ACCOUNT.ACC_ID)) EMPLOYEE_ACC_STATUS
                FROM PERSON
                    ,ACCOUNT
                    ,SCHEDULER_DETAILS
               WHERE SCHEDULER_DETAILS.SCHEDULER_ID(+) = '
                     || nvl(p_scheduler_id, 0)
                     || ' AND SCHEDULER_DETAILS.ACC_ID(+) = ACCOUNT.ACC_ID
                 AND PERSON.PERS_ID = ACCOUNT.PERS_ID
                 AND ACCOUNT.ACCOUNT_STATUS <> 4 AND NVL(ACCOUNT.SIGNATURE_ON_FILE,''N'') = ''Y''
                 AND PERSON.ENTRP_ID =  '
                     || p_entrp_id;

        else
            if p_scheduler_id is not null then
                l_sql := ' SELECT ACCOUNT.ACC_ID
                      ,ACCOUNT.ACC_NUM
                      ,PERSON.FIRST_NAME
                      ,PERSON.LAST_NAME
                      ,NVL(ER_AMOUNT,0) ER_AMOUNT
                      ,NVL(EE_AMOUNT,0) EE_AMOUNT
                      ,NVL(ER_FEE_AMOUNT,0)  ER_FEE_AMOUNT  -- Added by Joshi for 9382
                      ,NVL(EE_FEE_AMOUNT,0)  EE_FEE_AMOUNT
                      ,SCHEDULER_DETAIL_ID
--                      ,decode(PC_ACCOUNT.get_status (ACCOUNT.ACC_ID),''Closed'',''Terminated'',PC_ACCOUNT.get_status (ACCOUNT.ACC_ID)) EMPLOYEE_ACC_STATUS
                     , CASE WHEN ben_plan_enrollment_setup.status = ''A'' AND (ben_plan_enrollment_setup.effective_end_date IS NULL   OR ben_plan_enrollment_setup.effective_end_date >= TRUNC(sysdate)) THEN ''Active''
                            WHEN ben_plan_enrollment_setup.status IN (''I'',''A'') AND ben_plan_enrollment_setup.effective_end_date IS NOT NULL
                             AND ben_plan_enrollment_setup.effective_end_date < TRUNC(sysdate) THEN ''Terminated'' END EMPLOYEE_ACC_STATUS
                  FROM PERSON
                      ,ACCOUNT
                      ,SCHEDULER_DETAILS
                      ,BEN_PLAN_ENROLLMENT_SETUP
                      ,SCHEDULER_MASTER SM
                  WHERE SM.SCHEDULER_ID = '
                         || p_scheduler_id
                         || ' AND SCHEDULER_DETAILS.SCHEDULER_ID = '
                         || p_scheduler_id
                         || ' AND SCHEDULER_DETAILS.ACC_ID = ACCOUNT.ACC_ID
                    AND BEN_PLAN_ENROLLMENT_SETUP.ACC_ID = ACCOUNT.ACC_ID
                    AND BEN_PLAN_ENROLLMENT_SETUP.PLAN_TYPE =  '''
                         || p_plan_type
                         || ''''
                         || ' AND BEN_PLAN_ENROLLMENT_SETUP.STATUS = ''A''
                    AND PERSON.PERS_ID = ACCOUNT.PERS_ID
                    AND PERSON.ENTRP_ID = '
                         || p_entrp_id
                         || ' AND SCHEDULER_DETAILS.SCHEDULER_ID=SM.SCHEDULER_ID
                    AND SM.PAYMENT_START_DATE BETWEEN BEN_PLAN_ENROLLMENT_SETUP.PLAN_START_DATE
                    AND BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE
      UNION ';
  --END IF;   -- Commented by Swamy for Ticket#10453(Performance issue) 12/10/2021
                l_sql := l_sql
                         || ' SELECT distinct ACCOUNT.ACC_ID
              ,ACCOUNT.ACC_NUM
              ,PERSON.FIRST_NAME
              ,PERSON.LAST_NAME
              ,0 ER_AMOUNT
              ,0 EE_AMOUNT
              ,0  ER_FEE_AMOUNT  -- Added by Joshi for 9382
              ,0  EE_FEE_AMOUNT
              ,NULL SCHEDULER_DETAIL_ID
--              ,decode(PC_ACCOUNT.get_status (ACCOUNT.ACC_ID),''Closed'',''Terminated'',PC_ACCOUNT.get_status (ACCOUNT.ACC_ID)) EMPLOYEE_ACC_STATUS
              , CASE WHEN ben_plan_enrollment_setup.status = ''A'' AND (ben_plan_enrollment_setup.effective_end_date IS NULL  OR ben_plan_enrollment_setup.effective_end_date >= TRUNC(sysdate)) THEN ''Active''
                     WHEN ben_plan_enrollment_setup.status IN (''I'',''A'') AND ben_plan_enrollment_setup.effective_end_date IS NOT NULL
                      AND ben_plan_enrollment_setup.effective_end_date < TRUNC(sysdate) THEN ''Terminated'' END EMPLOYEE_ACC_STATUS
         FROM PERSON
             ,ACCOUNT
             ,BEN_PLAN_ENROLLMENT_SETUP
             ,SCHEDULER_MASTER SM
        WHERE BEN_PLAN_ENROLLMENT_SETUP.ACC_ID = ACCOUNT.ACC_ID
          AND BEN_PLAN_ENROLLMENT_SETUP.PLAN_TYPE = '''
                         || p_plan_type
                         || ''''
                         || ' AND PERSON.PERS_ID = ACCOUNT.PERS_ID
          AND BEN_PLAN_ENROLLMENT_SETUP.STATUS = ''A''
          AND PERSON.ENTRP_ID =  '
                         || p_entrp_id
                         || ' AND TRUNC(BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE) >= TRUNC(SYSDATE)
          AND TRUNC(NVL(BEN_PLAN_ENROLLMENT_SETUP.effective_end_date,SYSDATE)) >= TRUNC(SYSDATE) ';

      --IF P_Scheduler_Id IS NOT NULL THEN   -- Commented by Swamy for Ticket#10453(Performance issue) 12/10/2021
                l_sql := l_sql
                         || ' AND SM.SCHEDULER_ID =  '
                         || p_scheduler_id
                         || ' AND NOT EXISTS (SELECT *
                                                FROM SCHEDULER_DETAILS SD
                                               WHERE SD.SCHEDULER_ID = SM.SCHEDULER_ID
                                                 AND SD.ACC_ID= ACCOUNT.ACC_ID)
                              AND  SM.PAYMENT_start_DATE BETWEEN BEN_PLAN_ENROLLMENT_SETUP.PLAN_START_DATE
                              AND BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE ';
    -- Added below else condition by Swamy for Ticket#10453(Performance issue) 12/10/2021
            else
                l_sql := l_sql
                         || ' SELECT distinct ACCOUNT.ACC_ID
              ,ACCOUNT.ACC_NUM
              ,PERSON.FIRST_NAME
              ,PERSON.LAST_NAME
              ,0 ER_AMOUNT
              ,0 EE_AMOUNT
              ,0 ER_FEE_AMOUNT  -- Added by Joshi for 9382
              ,0 EE_FEE_AMOUNT
              ,NULL SCHEDULER_DETAIL_ID
--              ,decode(PC_ACCOUNT.get_status (ACCOUNT.ACC_ID),''Closed'',''Terminated'',PC_ACCOUNT.get_status (ACCOUNT.ACC_ID)) EMPLOYEE_ACC_STATUS
              ,CASE WHEN ben_plan_enrollment_setup.status = ''A'' AND (ben_plan_enrollment_setup.effective_end_date IS NULL  OR ben_plan_enrollment_setup.effective_end_date >= TRUNC(sysdate)) THEN ''Active''
                    WHEN ben_plan_enrollment_setup.status IN (''I'',''A'') AND ben_plan_enrollment_setup.effective_end_date IS NOT NULL
                     AND ben_plan_enrollment_setup.effective_end_date < TRUNC(sysdate) THEN ''Terminated'' END EMPLOYEE_ACC_STATUS
         FROM PERSON
             ,ACCOUNT
             ,BEN_PLAN_ENROLLMENT_SETUP
            -- ,SCHEDULER_MASTER SM  -- Commented by Swamy for Ticket#10453(Performance issue, this table is not used in the query, so removed it)
        WHERE BEN_PLAN_ENROLLMENT_SETUP.ACC_ID = ACCOUNT.ACC_ID
          AND BEN_PLAN_ENROLLMENT_SETUP.PLAN_TYPE = '''
                         || p_plan_type
                         || ''''
                         || ' AND PERSON.PERS_ID = ACCOUNT.PERS_ID
          AND BEN_PLAN_ENROLLMENT_SETUP.STATUS = ''A''
          AND (('''
                         || p_show_term_employee
                         || ''''
                         || ' = ''N'' AND (ben_plan_enrollment_setup.effective_end_date IS NULL
                OR (ben_plan_enrollment_setup.effective_end_date IS NOT NULL AND BEN_PLAN_ENROLLMENT_SETUP.effective_end_date > trunc(sysdate))))
           OR ('''
                         || p_show_term_employee
                         || ''''
                         || ' = ''Y'' AND (Ben_Plan_Enrollment_Setup.effective_end_date IS NOT NULL
                                AND (ben_plan_enrollment_setup.effective_end_date <= TRUNC(SYSDATE) OR ben_plan_enrollment_setup.effective_end_date >= TRUNC(SYSDATE))
                OR (ben_plan_enrollment_setup.effective_end_date IS NULL )))) -- added by Jaggi #11365
          AND PERSON.ENTRP_ID =  '
                         || p_entrp_id
                         || ' AND '
                         || 'to_date( '''
                         || p_plan_start_date
                         || ''',''mm/dd/yyyy'')'
                         || '  BETWEEN BEN_PLAN_ENROLLMENT_SETUP.PLAN_START_DATE
                             AND BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE 
            AND TRUNC(BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE) >= TRUNC(SYSDATE) ';                
--          AND TRUNC(NVL(BEN_PLAN_ENROLLMENT_SETUP.effective_end_date,SYSDATE)) >= TRUNC(SYSDATE) ' ;

            end if;
        end if;

        pc_log.log_error('pc_schedule.get_employee_schedule l_sql', l_sql);
        open c_cur for l_sql;

        loop
            fetch c_cur into l_record;
            exit when c_cur%notfound;
            pipe row ( l_record );
        end loop;

    end get_employee_schedule;

    procedure generate_calendar (
        p_schedule_id in number,
        p_paydates    pc_online_enrollment.varchar2_tbl,
        p_user_id     in number
    ) is
    begin
        for i in 1..p_paydates.count loop
            insert into scheduler_calendar (
                scalendar_id,
                schedule_id,
                period_date,
                created_by,
                last_updated_by
            ) values ( scheduler_calendar_seq.nextval,
                       p_schedule_id,
                       to_date(p_paydates(i),
                               'MM/DD/YYYY'),
                       0,
                       0 );

        end loop;
    end generate_calendar;

-- This is used to show the pending transactions for the employer in the contribution page.
    function get_emp_scheduler_detail (
        p_scheduler_id in number,
        p_acc_id       number,
        p_rec_freq     varchar2
    ) return scheduler_t
        pipelined
        deterministic
    is
        l_record scheduler_rec;
    begin
        for x in (
            select
                scheduler_id,
                a.plan_type,
                pc_lookups.get_meaning(a.plan_type, 'FSA_PLAN_TYPE')   plan_type_meaning,
                a.recurring_flag,
                a.recurring_frequency,
                pc_lookups.get_payroll_frequncy(a.recurring_frequency) recurring_frequency_desc,
                payment_start_date,
                payment_end_date,
                a.amount,
                a.note,
                f.fee_name                                             contribution_type
            from
                scheduler_master a,
                account          b,
                calendar_master  c,
                fee_names        f
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.reason_code = f.fee_code
                and a.calendar_id = c.calendar_id (+)
                and c.calendar_type = 'PAYROLL_CONTRIBUTION'
                and nvl(recurring_flag, 'N') = p_rec_freq
                and ( a.status is null
                      or a.status not in ( 'D', 'P' ) )
                and ( ( recurring_flag = 'Y'
                        and exists (
                    select
                        *
                    from
                        scheduler_calendar
                    where
                            schedule_id = a.scheduler_id
                        and trunc(period_date) >= trunc(sysdate)
                ) )
                      or ( recurring_flag = 'N' ) --AND trunc(payment_start_date) >=  trunc(sysdate)) -- commented By Jaggi #11365 & 11487
                       )
        ) loop
            l_record.scheduler_id := x.scheduler_id;
            l_record.plan_type := x.plan_type;
            l_record.plan_type_desc := x.plan_type_meaning;
            l_record.recurring_flag := x.recurring_flag;
            l_record.recurring_freq := x.recurring_frequency;
            l_record.recurring_freq_desc := x.recurring_frequency_desc;
            l_record.payment_start_date := x.payment_start_date;
            l_record.payment_end_date := x.payment_end_date;
            l_record.total_amount := x.amount;
            l_record.note := x.note;
            l_record.contribution_type := x.contribution_type;
            pipe row ( l_record );
        end loop;
    end get_emp_scheduler_detail;

---over loaded function to get the scheuler deail used in ths contribution for EDIT/VIEW componet.
    function get_schedule_detail (
        p_scheduler_id in number,
        p_rec_freq     varchar2
    ) return scheduler_t
        pipelined
        deterministic
    is
        l_record    scheduler_rec;
        l_next_date varchar2(20);
        l_processed number := 0;
    begin
        if p_rec_freq = 'Y' then
            select
                count(*)
            into l_processed
            from
                scheduler_master a
            where
                    a.scheduler_id = p_scheduler_id
                and exists (
                    select
                        *
                    from
                        scheduler_calendar
                    where
                            schedule_id = a.scheduler_id
                        and trunc(period_date) >= trunc(sysdate)
                );

            if l_processed = 0 then
                l_record.error_message := 'The selcted transaction is already processed';
                pipe row ( l_record );
            end if;

        else
            select
                count(*)
            into l_processed
            from
                scheduler_master
            where
                    scheduler_id = p_scheduler_id
                and nvl(status, 'A') = 'A'; -- added by jaggi #11487 & 11365
--      AND trunc(payment_start_date) >=  trunc(sysdate) ;
            if l_processed = 0 then
                l_record.error_message := 'The selcted transaction is already processed';
                pipe row ( l_record );
            end if;

        end if;

        if l_processed > 0 then
            for x in (
                select
                    to_char(period_date, 'MM/DD/YYYY') period_date
                from
                    (
                        select
                            a.*,
                            rank()
                            over(
                                order by
                                    period_date
                            ) as rank_date
                        from
                            scheduler_calendar a
                        where
                                a.schedule_id = p_scheduler_id
                            and period_date > sysdate
                    )
                where
                    rank_date = 1
            ) loop
                l_next_date := x.period_date;
            end loop;

            for x in (
                select
                    a.scheduler_id,
                    a.plan_type,
                    pc_lookups.get_meaning(a.plan_type, 'FSA_PLAN_TYPE')   plan_type_meaning,
                    a.recurring_flag,
                    a.recurring_frequency,
                    pc_lookups.get_payroll_frequncy(a.recurring_frequency) recurring_frequency_desc,
                    to_char(payment_start_date, 'MM/DD/YYYY')              payment_start_date,
                    to_char(payment_end_date, 'MM/DD/YYYY')                payment_end_date,
                    a.amount,
                    a.note,
                    to_char(
                        max(p.plan_start_date),
                        'MM/DD/YYYY'
                    )                                                      plan_start_date,
                    a.reason_code                                          reason_code,
                    a.bank_acct_id                                         bank_acct_id,
                    a.no_of_pay_period                 -- added by jaggi #11365
                    ,
                    a.post_prev_pay_period             -- added by jaggi #11600
                from
                    scheduler_master          a,
                    ben_plan_enrollment_setup p
                where
                        a.acc_id = p.acc_id (+)
                    and a.plan_type = p.plan_type (+)
                --AND A.PAYMENT_END_DATE = p.PLAN_END_DATE(+)
                    and scheduler_id = p_scheduler_id
                group by
                    a.scheduler_id,
                    a.plan_type,
                    pc_lookups.get_meaning(a.plan_type, 'FSA_PLAN_TYPE'),
                    a.recurring_flag,
                    a.recurring_frequency,
                    pc_lookups.get_payroll_frequncy(a.recurring_frequency),
                    to_char(payment_start_date, 'MM/DD/YYYY'),
                    to_char(payment_end_date, 'MM/DD/YYYY'),
                    a.amount,
                    a.note,
                    a.reason_code,
                    a.bank_acct_id,
                    a.no_of_pay_period,
                    a.post_prev_pay_period
            ) loop
                l_record.scheduler_id := x.scheduler_id;
                l_record.plan_type := x.plan_type;
                l_record.plan_type_desc := x.plan_type_meaning;
                l_record.recurring_flag := x.recurring_flag;
                l_record.recurring_freq := x.recurring_frequency;
                l_record.recurring_freq_desc := x.recurring_frequency_desc;
                l_record.payment_start_date := x.payment_start_date;
                l_record.payment_end_date := x.payment_end_date;
                l_record.plan_start_date := x.plan_start_date;
                l_record.plan_end_date := x.payment_end_date;
                l_record.next_process_date := l_next_date;
                l_record.total_amount := x.amount;
                l_record.note := x.note;
                l_record.reason_code := x.reason_code;
                l_record.contribution_type := pc_lookups.get_fee_reason(x.reason_code);
                l_record.bank_acct_id := x.bank_acct_id;
                l_record.no_of_pay_period := x.no_of_pay_period;      -- added by jaggi #11365
                l_record.post_prev_pay_period := x.post_prev_pay_period;  -- added by jaggi #11600

                if x.bank_acct_id is not null then
                    for xx in (
                        select
                            display_name,
                            bank_acct_num
                        from
                            user_bank_acct
                        where
                            bank_acct_id = x.bank_acct_id
                    ) loop
                        l_record.bank_name := xx.display_name;
                        l_record.bank_acct_num := xx.bank_acct_num;
                    end loop;
                end if;

                pipe row ( l_record );
            end loop;

        end if;

    end get_schedule_detail;

    procedure mass_insert_scheduler_details (
        p_batch_number  number,
        p_scheduler_id  in out number,
        p_acc_id        pc_online_enrollment.varchar2_tbl,
        p_er_amount     pc_online_enrollment.varchar2_tbl,
        p_ee_amount     pc_online_enrollment.varchar2_tbl,
        p_er_fee_amount pc_online_enrollment.varchar2_tbl,
        p_ee_fee_amount pc_online_enrollment.varchar2_tbl,
        p_user_id       number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_total_amount        number := 0;
        l_total_fee_amount    number := 0;
        x_scheduler_detail_id number;
        l_return_status       varchar2(1);
        l_error_message       varchar2(255);
        l_scheduler_det_error exception;
    begin
        x_return_status := 'S';
        pc_log.log_error('calling MASS_INSERT_SCHEDULER_DETAILS: ', 'P_ACC_ID.count' || p_acc_id.count);
        for ind in p_acc_id.first..p_acc_id.last loop
            pc_schedule.ins_scheduler_details(
                p_scheduler_id        => p_scheduler_id,
                p_acc_id              => p_acc_id(ind),
                p_er_amount           => p_er_amount(ind),
                p_ee_amount           => p_ee_amount(ind),
                p_er_fee_amount       => p_er_fee_amount(ind),
                p_ee_fee_amount       => p_ee_fee_amount(ind),
                p_user_id             => p_user_id,
                p_note                => null,
                x_scheduler_detail_id => x_scheduler_detail_id,
                x_return_status       => l_return_status,
                x_error_message       => l_error_message
            );

            if l_return_status = 'S' then
                update scheduler_details_stg
                set
                    scheduler_detail_id = x_scheduler_detail_id,
                    status = 'P',
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                        batch_number = p_batch_number
                    and acc_id = p_acc_id(ind)
                    and status = 'U';

            -- update the status to 'A' for terminated
                update scheduler_details
                set
                    status = 'A'
                where
                        scheduler_id = p_scheduler_id
                    and ( er_amount > 0
                          or ee_amount > 0 )
                    and status = 'I';

            else
                raise l_scheduler_det_error;
            end if;

        end loop;

        if x_return_status = 'S' then

       -- commented and added below line for 9382.
       --SELECT SUM(NVL(ER_AMOUNT,0)+ NVL(EE_AMOUNT,0))
            select
                sum(nvl(er_amount, 0) + nvl(ee_amount, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0))
            into l_total_amount --, l_total_fee_amount
            from
                scheduler_details
            where
                    scheduler_id = p_scheduler_id
                and status = 'A';

            if l_total_amount > 0 then
                update scheduler_master
                set
                    amount = l_total_amount
                 --fee_amount = l_total_fee_amount -- added by Joshi 9382
                where
                    scheduler_id = p_scheduler_id;

            end if;

        end if;

    exception
        when l_scheduler_det_error then
            x_return_status := 'E';
            x_error_message := l_error_message;
        when others then
            pc_log.log_error(' MASS_INSERT_SCHEDULER_DETAILS:', 'others' || sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end mass_insert_scheduler_details;

-- Process sheduler detail record added from online or uploaded through Excel file.
    procedure process_online_scheduler_det (
        p_batch_number  in number,
        p_file_name     in varchar2,
        p_scheduler_id  in out number,
        p_ee_acc_id     in pc_online_enrollment.varchar2_tbl,
        p_er_amount     in pc_online_enrollment.varchar2_tbl,
        p_ee_amount     in pc_online_enrollment.varchar2_tbl,
        p_er_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_ee_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_user_id       in number,
        p_confirm_flag  in varchar2 default 'N',
        p_memo          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        app_exception exception;
        l_acc_id_tbl    pc_online_enrollment.varchar2_tbl;
        l_er_amount_tbl pc_online_enrollment.varchar2_tbl;
        l_ee_amount_tbl pc_online_enrollment.varchar2_tbl;
        l_er_fee_tbl    pc_online_enrollment.varchar2_tbl;
        l_ee_fee_tbl    pc_online_enrollment.varchar2_tbl;
        l_return_status varchar2(1);
        l_error_message varchar2(2000);
        l_scheduler_det_error exception;
    begin
        x_return_status := 'S';




-- insert the data into Staging table.
        if p_file_name is null then
            pc_schedule.insert_online_schd_stg_det(
                p_batch_number  => p_batch_number,
                p_scheduler_id  => p_scheduler_id,
                p_ee_acc_id     => p_ee_acc_id,
                p_er_amount     => p_er_amount,
                p_ee_amount     => p_ee_amount,
                p_er_fee_amount => p_er_fee_amount,
                p_ee_fee_amount => p_ee_fee_amount,
                p_user_id       => p_user_id,
                x_error_message => l_error_message,
                x_return_status => l_return_status
            );

            if l_return_status <> 'S' then
                raise app_exception;
            end if;
        else
            pc_log.log_error('pc_Scheduler: ', 'Entered initialize_scheduler part');
            pc_schedule.initialize_scheduler(
                p_batch_number  => p_batch_number,
                p_scheduler_id  => p_scheduler_id,
                p_user_id       => p_user_id,
                x_error_message => x_error_message,
                x_return_status => x_return_status
            );

            if x_return_status <> 'S' then
                raise l_scheduler_det_error;
            end if;
            pc_log.log_error('pc_Scheduler: ', 'Entered validate_scheduler proc');
            pc_schedule.validate_scheduler(
                p_batch_number  => p_batch_number,
                x_error_message => x_error_message,
                x_return_status => x_return_status
            );
       /*
       IF x_return_status <> 'S' THEN
            RAISE l_scheduler_det_error;
       END IF;
        */
        end if;

        if p_confirm_flag = 'Y' then

        -- update note.
            if p_memo is not null then
                update scheduler_stage
                set
                    note = p_memo
                where
                    batch_number = p_batch_number;

                update scheduler_master
            --set note= note ||' ' || p_memo
                set
                    note = p_memo    -- Commented above and added by Swamy for Ticket#10331 on 13/09/2021
                where
                    scheduler_id = p_scheduler_id;

            end if;

            select
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount
            bulk collect
            into
                l_acc_id_tbl,
                l_er_amount_tbl,
                l_ee_amount_tbl,
                l_er_fee_tbl,
                l_ee_fee_tbl
            from
                scheduler_details_stg
            where
                    batch_number = p_batch_number
                and nvl(status, 'U') = 'U'
                and scheduler_id = p_scheduler_id; -- added by jaggi #11365
       --AND   entrp_id= x.entrp_id;
            pc_log.log_error('process_online_scheduler_det: ', 'calling MASS_INSERT_SCHEDULER_DETAILS');
            pc_schedule.mass_insert_scheduler_details(
                p_batch_number  => p_batch_number,
                p_scheduler_id  => p_scheduler_id,
                p_acc_id        => l_acc_id_tbl,
                p_er_amount     => l_er_amount_tbl,
                p_ee_amount     => l_ee_amount_tbl,
                p_er_fee_amount => l_er_fee_tbl,
                p_ee_fee_amount => l_ee_fee_tbl,
                p_user_id       => p_user_id,
                x_return_status => l_return_status,
                x_error_message => l_error_message
            );

            if x_return_status <> 'S' then
                raise l_scheduler_det_error;
            end if;
        end if;

    exception
        when app_exception then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_message;
            pc_log.log_error('process_online_scheduler_det', l_error_message);
            pc_log.log_error('process_online_scheduler_det - SQL msg', sqlerrm);
        when l_scheduler_det_error then
  -- ROLLBACK;
            x_return_status := 'E';
            x_error_message := l_error_message;
            pc_log.log_error('process_online_scheduler_det', l_error_message);
            pc_log.log_error('process_online_scheduler_det - SQL msg', sqlerrm);
    end process_online_scheduler_det;

    procedure delete_scheduler_line (
        p_scheduler_id  in number,
        p_ee_acc_id     in number,
        p_batch_number  in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        update scheduler_details_stg
        set
            status = 'I',
            er_amount = 0,
            ee_amount = 0,
            er_fee_amount = 0,
            ee_fee_amount = 0,
            last_updated_by = p_user_id,
            last_updated_date = sysdate
        where
                scheduler_id = p_scheduler_id
            and acc_id = p_ee_acc_id
    --AND batch_number = p_batch_number ;
            and batch_number = nvl(p_batch_number, batch_number); --  Added by Joshi for 9382

        update scheduler_details
        set
            status = 'I',
            er_amount = 0,
            ee_amount = 0,
            er_fee_amount = 0,
            ee_fee_amount = 0,
            last_updated_by = p_user_id,
            last_updated_date = sysdate
        where
                scheduler_id = p_scheduler_id
            and acc_id = p_ee_acc_id;

        for x in (
            select
                sum(er_amount + ee_amount)         amount,
                sum(er_fee_amount + ee_fee_amount) fee_amount
            from
                scheduler_details
            where
                    status = 'A'
                and scheduler_id = p_scheduler_id
        ) loop
            update scheduler_master
            set
                amount = x.amount + nvl(x.fee_amount, 0)  --  Added by Joshi for 9382
          -- ,fee_amount = x.fee_amount
            where
                scheduler_id = p_scheduler_id;

        end loop;

        x_return_status := 'S';
        x_error_message := 'Your request has been completed successfully';
    exception
        when others then
            x_return_status := 'E';
            x_error_message := 'Employee contribution can not be deleted. Please contact system administrator';
    end delete_scheduler_line;

    procedure run_sameday_scheduler as
    begin
        for x in (
            select
                scheduler_id,
                s.acc_id                                                    m_acc_id,
                payment_method,
                payment_type,
                reason_code,
                payment_start_date,
                payment_end_date,
                recurring_flag,
                amount,
                fee_amount,
                bank_acct_id,
                contributor,
                plan_type,
                decode(orig_system_source, 'CLAIMN', orig_system_ref, null) claim_id,
                created_by
            from
                scheduler_master s
            where
                    trunc(payment_start_date) = trunc(sysdate)
                and payment_method = 'PAYROLL'
                and recurring_flag = 'Y'
                and nvl(s.status, 'A') = 'A'
                -- Added by Joshi for 12336
            union
            select
                scheduler_id,
                s.acc_id                                                    m_acc_id,
                payment_method,
                payment_type,
                reason_code,
                payment_start_date,
                payment_end_date,
                recurring_flag,
                amount,
                fee_amount,
                bank_acct_id,
                contributor,
                plan_type,
                decode(orig_system_source, 'CLAIMN', orig_system_ref, null) claim_id,
                created_by
            from
                scheduler_master s
            where
                    trunc(payment_end_date) = trunc(sysdate)
                and payment_method = 'PAYROLL'
                and recurring_flag = 'N'
                and nvl(s.status, 'A') = 'A'
        ) loop
            pc_schedule.process_schedule(x.scheduler_id, null, x.created_by);
        end loop;
    end run_sameday_scheduler;

/** EDI Processing ***/
    procedure schedule_edi_payroll (
        pv_file_name in varchar2
    ) is
        l_batch_number number;
    begin
        l_batch_number := batch_num_seq.nextval;
        export_payroll_contri_file(pv_file_name, l_batch_number);
        insert_into_staging(l_batch_number, pv_file_name);
        initialize_edi_scheduler(l_batch_number);
        validate_edi_scheduler(l_batch_number);
        process_edi_scheduler(l_batch_number);
    end schedule_edi_payroll;

    procedure export_payroll_contri_file (
        pv_file_name in varchar2,
        p_user_id    in number
    ) as

        l_file       utl_file.file_type;
        l_buffer     raw(32767);
        l_amount     binary_integer := 32767;
        l_pos        integer := 1;
        l_blob       blob;
        l_blob_len   integer;
        exc_no_file exception;
        l_create_ddl varchar2(32000);
        lv_dest_file varchar2(300);
        lv_create exception;
        l_sqlerrm    varchar2(32000);
        l_create_error exception;
        l_row_count  number := -1;
    begin
        begin
            execute immediate '
			   ALTER TABLE PAYROLL_SCHEDULER_EXTERNAL
			    location (SCHEDULER_DIR:'''
                              || pv_file_name
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of Scheduler Detail file' || sqlerrm;
                raise l_create_error;
        end;
    exception
        when lv_create then
            rollback;
            raise_application_error('-20001', 'Payroll   file seems to be corrupted, Use correct template');
        when others then
            rollback;
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_payroll_contri_file;

    procedure insert_into_staging (
        p_batch_number in number,
        p_file_name    in varchar2
    ) is
    begin
        begin
            insert into scheduler_stage (
                scheduler_stage_id,
                batch_number,
                entrp_id,
                plan_type,
                reason_name,
                payroll_date,
                recurring_flag,
                recurring_frequency,
                er_acc_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                status,
                note
            )
                select
                    scheduler_stage_seq.nextval,
                    p_batch_number,
                    pc_entrp.get_entrp_id(er_acc_num),
                    plan_type,
                    reason_name,
                    payroll_date,
                    'N',
                    upper(pay_frequency),
                    pc_account.get_acc_id(er_acc_num),
                    sysdate,
                    0,
                    sysdate,
                    0,
                    'U',
                    'EDI:' || p_file_name
                from
                    (
                        select distinct
                            er_acc_num,
                            plan_type,
                            reason_name,
                            payroll_date,
                            pay_frequency
                        from
                            payroll_scheduler_external
                    );

        exception
            when others then
                raise_application_error('-20001', 'Error inINSERTING INTO SCHEDULER_STAGE ' || sqlerrm);
        end;

        begin
            insert into scheduler_details_stg (
                sch_det_stg_id,
                acc_num,
                ssn,
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                batch_number,
                created_by,
                creation_date,
                last_updated_by,
                last_updated_date,
                status,
                first_name,
                last_name,
                scheduler_stage_id
            )
                select
                    scheduler_details_stg_seq.nextval,
                    null,
                    ssn,
                    pc_account.get_acc_id_from_ssn(ssn, b.entrp_id),
                    employer_amount,
                    employee_amount,
                    employer_fee,
                    employee_fee,
                    p_batch_number,
                    0,
                    sysdate,
                    0,
                    sysdate,
                    'U',
                    first_name,
                    last_name,
                    b.scheduler_stage_id
                from
                    payroll_scheduler_external a,
                    scheduler_stage            b
                where
                        b.entrp_id = pc_entrp.get_entrp_id(er_acc_num)
                    and b.batch_number = p_batch_number
                    and a.plan_type = b.plan_type
                    and a.payroll_date = b.payroll_date;

        exception
            when others then
                raise_application_error('-20001', 'Error inINSERTING INTO SCHEDULER_DETAIL_STAGE ' || sqlerrm);
        end;

    end insert_into_staging;

    procedure initialize_edi_scheduler (
        p_batch_number in number
    ) is
    begin
        update scheduler_stage s
        set
            ben_plan_id = (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup bp
                where
                        bp.plan_type = s.plan_type
                    and to_date(s.payroll_date, 'MM/DD/YYYY') between bp.plan_start_date and bp.plan_end_date
                    and bp.entrp_id = s.entrp_id
            )
        where
            batch_number = p_batch_number;

        update scheduler_details_stg s
        set
            acc_num = pc_account.get_acc_num_from_acc_id(acc_id)
        where
            batch_number = p_batch_number;

    exception
        when others then
            raise_application_error('-20001', 'Error inI initialize_EDI_scheduler ' || sqlerrm);
    end initialize_edi_scheduler;

    procedure validate_edi_scheduler (
        p_batch_number in number
    ) is
    begin
      -- initializing
        update scheduler_stage
        set
            status = 'U'
        where
            batch_number = p_batch_number;

        update scheduler_stage
        set
            error_message = 'Employer does not allow EDI Payroll feeds',
            status = 'E'
        where
                batch_number = p_batch_number
            and 'Y' <> (
                select
                    nvl(allow_payroll_edi, 'N')
                from
                    account_preference
                where
                    entrp_id = scheduler_stage.entrp_id
            )
            and nvl(status, 'U') = 'U';

        update scheduler_stage
        set
            error_message =
                case
                    when is_date(payroll_date, 'MM/DD/YYYY') <> 'Y' then
                        'Enter valid payroll date'
                end,
            status =
                case
                    when is_date(payroll_date, 'MM/DD/YYYY') = 'Y' then
                        'U'
                    else
                        'E'
                end
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U';

        update scheduler_stage
        set
            error_message = 'Cannot derive employer benefit plan ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and ben_plan_id is null;

        update scheduler_stage
        set
            error_message = 'Enter valid reason ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and upper(reason_name) <> 'PAYROLL CONTRIBUTION';

        update scheduler_stage
        set
            error_message = 'Enter valid plan type ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and plan_type is null;

        update scheduler_stage
        set
            error_message = 'Enter valid plan type ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and not exists (
                select
                    *
                from
                    fsa_hra_plan_type
                where
                    lookup_code = plan_type
            );

        update scheduler_stage
        set
            error_message = 'Enter valid frequency',
            status = 'E'
        where
                batch_number = p_batch_number
            and recurring_frequency is not null
            and status = 'U'
            and not exists (
                select
                    *
                from
                    lookups
                where
                        lookup_name = 'PAYROLL_FREQUENCY'
                    and meaning = recurring_frequency
            );

        update scheduler_stage
        set
            error_message = 'Cannot derive employer account  ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and er_acc_id is null;

        update scheduler_stage
        set
            error_message = 'Cannot derive employer id ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and entrp_id is null;

        update scheduler_details_stg
        set
            error_message =
                case
                    when is_number(er_amount) <> 'Y' then
                        'Enter numeric value for Employee Fee'
                end,
            status =
                case
                    when is_number(er_amount) = 'Y' then
                        'U'
                    else
                        'E'
                end
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U';

        update scheduler_details_stg
        set
            error_message =
                case
                    when is_number(ee_amount) = 'Y' then
                        null
                    else
                        'Enter numeric value for Employee Fee'
                end,
            status =
                case
                    when is_number(ee_amount) = 'Y' then
                        'U'
                    else
                        'E'
                end
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U';

        update scheduler_details_stg
        set
            error_message =
                case
                    when is_number(er_fee_amount) = 'Y' then
                        null
                    else
                        'Enter numeric value for Employer Fee'
                end,
            status =
                case
                    when is_number(er_fee_amount) = 'Y' then
                        'U'
                    else
                        'E'
                end
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U';

        update scheduler_details_stg
        set
            error_message =
                case
                    when is_number(ee_fee_amount) = 'Y' then
                        null
                    else
                        'Enter numeric value for Employee Fee'
                end,
            status =
                case
                    when is_number(ee_fee_amount) = 'Y' then
                        'U'
                    else
                        'E'
                end
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U';

	 /*
	    UPDATE SCHEDULER_DETAILS_STG
	    SET    error_message   = CASE WHEN  NVL(ER_AMOUNT,0)+NVL(Ee_AMOUNT,0)+NVL(ER_FEE_AMOUNT,0)+NVL(EE_FEE_AMOUNT,0) = 0 THEN
				'Payroll contribution cannot be zero for plan types other than transit and parking'
			    ELSE NULL END
		  ,status = CASE WHEN  NVL(ER_AMOUNT,0)+NVL(Ee_AMOUNT,0)+NVL(ER_FEE_AMOUNT,0)+NVL(EE_FEE_AMOUNT,0) = 0 THEN
				'E'
			    ELSE NULL END
	    WHERE  batch_number = P_batch_number and plan_type NOT IN ('TRN','PKG','UA1')
	    AND    status = 'U';*/

        update scheduler_details_stg
        set
            error_message = 'Enter valid SSN of employee ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and ssn is null;

        update scheduler_details_stg
        set
            error_message = 'Cannot derive employee account number ',
            status = 'E'
        where
                batch_number = p_batch_number
            and nvl(status, 'U') = 'U'
            and acc_id is null;

    exception
        when others then
            raise_application_error('-20001', 'Error inI validate_edi_scheduler ' || sqlerrm);
    end validate_edi_scheduler;

    procedure process_edi_scheduler (
        p_batch_number in number
    ) is

        l_scheduler_id  number;
        l_return_status varchar2(1);
        l_error_message varchar2(2000);
        l_acc_id_tbl    pc_schedule.number_tbl;
        l_er_amount_tbl pc_schedule.number_tbl;
        l_ee_amount_tbl pc_schedule.number_tbl;
        l_er_fee_tbl    pc_schedule.number_tbl;
        l_ee_fee_tbl    pc_schedule.number_tbl;
        l_sch_det_tbl   pc_schedule.number_tbl;
        l_stage_det_id  pc_schedule.number_tbl;
        l_scheduler_det_error exception;
        l_scheduler_error exception;
        l_pay_dates     pc_online_enrollment.varchar2_tbl;
        l_total_amount  number := 0;
    begin
        for x in (
            select
                s.er_acc_id,
                pc_entrp.get_entrp_name(s.entrp_id)                      name,
                sum(nvl(sd.er_amount, 0) + nvl(sd.ee_amount, 0))         amount,
                sum(nvl(sd.er_fee_amount, 0) + nvl(sd.ee_fee_amount, 0)) fee_amount,
                s.plan_type,
                s.entrp_id,
                e.entrp_code,
                s.scheduler_stage_id,
                s.payroll_date
            from
                scheduler_stage       s,
                scheduler_details_stg sd,
                enterprise            e
            where
                    s.batch_number = p_batch_number
                and s.batch_number = sd.batch_number
                and s.entrp_id = e.entrp_id
                and s.scheduler_stage_id = sd.scheduler_stage_id
                and nvl(sd.status, 'U') = 'U'
                and nvl(s.status, 'U') = 'U'
                and s.ben_plan_id is not null
                and s.entrp_id is not null
                and sd.acc_id is not null
            group by
                s.er_acc_id,
                s.entrp_id,
                e.entrp_code,
                s.plan_type,
                s.scheduler_stage_id,
                s.payroll_date
        ) loop
            l_scheduler_id := null;
            l_return_status := null;
            pc_schedule.ins_scheduler(
                p_acc_id              => x.er_acc_id,
                p_name                => x.name,
                p_payment_method      => 'PAYROLL',
                p_payment_type        => 'C',
                p_reason_code         => 11,
                p_payment_start_date  => to_date(x.payroll_date, 'MM/DD/YYYY'),
                p_payment_end_date    =>
                                    case
                                        when sysdate - to_date(x.payroll_date, 'MM/DD/YYYY') > 0 then
                                            sysdate + 1
                                        else
                                            to_date(x.payroll_date, 'MM/DD/YYYY') + 1
                                    end,
                p_recurring_flag      => 'N',
                p_recurring_frequency => null,
                p_amount              => x.amount,
                p_fee_amount          => x.fee_amount,
                p_bank_acct_id        => null,
                p_contributor         => x.entrp_id,
                p_plan_type           => x.plan_type,
                p_orig_system_source  => null,
                p_orig_system_ref     => null,
                p_pay_to_all          => 'N',
                p_pay_to_all_amount   => null,
                p_source              => 'EDI',
                p_pay_dates           => l_pay_dates,
                p_user_id             => 0,
                p_note                => 'Created by EDI',
                x_scheduler_id        => l_scheduler_id,
                x_return_status       => l_return_status,
                x_error_message       => l_error_message
            );

            if l_return_status = 'S' then
                update scheduler_stage
                set
                    scheduler_id = l_scheduler_id
                where
                        entrp_id = x.entrp_id
                    and batch_number = p_batch_number
                    and plan_type = x.plan_type
                    and payroll_date = x.payroll_date;

                update scheduler_stage
                set
                    status = 'S'
                where
                        scheduler_stage_id = x.scheduler_stage_id
                    and batch_number = p_batch_number
                    and plan_type = x.plan_type
                    and payroll_date = x.payroll_date;

            else
                update scheduler_stage
                set
                    status = 'E',
                    error_message = l_error_message
                where
                        scheduler_stage_id = x.scheduler_stage_id
                    and batch_number = p_batch_number
                    and plan_type = x.plan_type
                    and payroll_date = x.payroll_date;

                update scheduler_details_stg
                set
                    status = 'E',
                    error_message = l_error_message
                where
                        scheduler_stage_id = x.scheduler_stage_id
                    and batch_number = p_batch_number;

            end if;

            select
                acc_id,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                sch_det_stg_id
            bulk collect
            into
                l_acc_id_tbl,
                l_er_amount_tbl,
                l_ee_amount_tbl,
                l_er_fee_tbl,
                l_ee_fee_tbl,
                l_stage_det_id
            from
                scheduler_details_stg
            where
                    batch_number = p_batch_number
                and nvl(status, 'U') = 'U'
                and scheduler_stage_id = x.scheduler_stage_id;

            pc_schedule.mass_ins_scheduler_details(
                p_scheduler_id        => l_scheduler_id,
                p_acc_id              => l_acc_id_tbl,
                p_er_amount           => l_er_amount_tbl,
                p_ee_amount           => l_ee_amount_tbl,
                p_er_fee_amount       => l_er_fee_tbl,
                p_ee_fee_amount       => l_ee_fee_tbl,
                p_user_id             => 0,
                x_scheduler_detail_id => l_sch_det_tbl,
                x_return_status       => l_return_status,
                x_error_message       => l_error_message
            );

            if l_return_status = 'S' then
                for i in 1..l_sch_det_tbl.count loop
                    update scheduler_details_stg
                    set
                        scheduler_id = l_scheduler_id,
                        scheduler_detail_id = l_sch_det_tbl(i)
                    where
                            scheduler_stage_id = x.scheduler_stage_id
                        and sch_det_stg_id = l_stage_det_id(i)
                        and batch_number = p_batch_number;

                    update scheduler_details_stg
                    set
                        status = 'S'
                    where
                            scheduler_stage_id = x.scheduler_stage_id
                        and sch_det_stg_id = l_stage_det_id(i)
                        and batch_number = p_batch_number;

                end loop;
            else
                update scheduler_details_stg
                set
                    status = 'E',
                    error_message = l_error_message
                where
                        scheduler_stage_id = x.scheduler_stage_id
                    and batch_number = p_batch_number;

                update scheduler_stage
                set
                    status = 'E',
                    error_message = l_error_message
                where
                        scheduler_stage_id = x.scheduler_stage_id
                    and batch_number = p_batch_number;

            end if;

            select
                sum(nvl(er_amount, 0) + nvl(ee_amount, 0) + nvl(ee_fee_amount, 0) + nvl(er_fee_amount, 0))
            into l_total_amount
            from
                scheduler_details
            where
                scheduler_id = l_scheduler_id;

            if l_total_amount > 0 then
                update scheduler_master
                set
                    amount = l_total_amount
                where
                    scheduler_id = l_scheduler_id;

            end if;

            -- Send schedule confirmation notification to Employer.
            pc_notifications.send_schedule_confirm_email(x.entrp_code, x.er_acc_id, 0);
        end loop;
      -- Process the scheduler
        for x in (
            select
                scheduler_id
            from
                scheduler_stage
            where
                    batch_number = p_batch_number
                and status = 'S'
                and to_date(payroll_date, 'MM/DD/YYYY') <= trunc(sysdate)
        ) loop
            pc_schedule.process_schedule(x.scheduler_id, null, 0);
        end loop;

        for x in (
            select distinct
                entrp_id
            from
                scheduler_stage
            where
                    batch_number = p_batch_number
                and status = 'S'
        ) loop
            pc_invoice.run_payroll_invoice(
                trunc(sysdate),
                x.entrp_id
            );
        end loop;

    exception
        when others then
            raise_application_error('-20001', 'Error inI process_edi_scheduler ' || sqlerrm);
    end process_edi_scheduler;

-- Added by Joshi to fix the pay per amount prod issue(#8127).
    function get_frequency (
        p_frequency  in varchar2,
        p_start_date in date,
        p_end_date   in date
    ) return number is

        l_trans_date_list pc_schedule.schedule_date_table;
        l_trans_dt        date;
        l_cnt             number := 0;
        l_period_list     pc_schedule.schedule_date_table;
        l_count           number := 0;
    begin
        if p_frequency = 'WEEKLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 52
            )
            select
                period_date
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(p_start_date, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'BIWEEKLY' then
            with data as (
                select
                    2 * level k
                from
                    dual
                connect by
                    level <= 26
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(p_start_date, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'SEMIMONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(trunc(p_start_date, 'MM') + 14,
                                   k) period_date
                    from
                        data
                    union
                    select
                        add_months(
                            last_day(p_start_date),
                            k
                        ) period_date
                    from
                        data
                    where
                        add_months(
                            last_day(p_start_date),
                            k
                        ) > p_start_date
                    order by
                        1
                )
            where
                    period_date >= p_start_date
                and period_date <= p_end_date;

        elsif p_frequency = 'MONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(
                            trunc(p_start_date, 'MM'),
                            k
                        ) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= p_end_date;

        elsif p_frequency = 'QUARTERLY' then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        decode(rownum,
                               1,
                               p_start_date,
                               add_months(p_start_date, rownum * 3)) period_date
                    from
                        all_objects
                    where
                        rownum <= 4
                )
            where
                trunc(period_date) <= trunc(p_end_date);

        elsif p_frequency = 'BIANNUALLY' then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        decode(rownum,
                               1,
                               p_start_date,
                               add_months(p_start_date, rownum * 6)) period_date
                    from
                        all_objects
                    where
                        rownum <= 2
                )
            where
                period_date <= p_end_date;

        end if;

        l_cnt := l_trans_date_list.count;
        if p_frequency = 'ANNUALLY' then
            l_trans_date_list(l_trans_date_list.count + 1) := p_start_date;
        else
            if p_frequency = 'BIWEEKLY' then
                l_cnt := l_cnt + 1;
                if l_cnt > 26 then    ----  rprabu issue raised by Franco fixed on 12/12/2019
                    l_cnt := 26;
                end if;
            end if;

            if p_frequency in ( 'QUARTERLY', 'SEMIMONTHLY' ) then
                if p_end_date <> l_trans_date_list(l_trans_date_list.count) then
                    l_cnt := l_cnt + 1;
                end if;

            end if;

        end if;

	  --IF l_trans_date_list.COUNT > 0 THEN
        return ( l_cnt );
	  --END IF ;

    end get_frequency;

/*** End of EDI Processing ***/

-- Added by Jaggi #9382
    function copy_schedule_detail (
        p_scheduler_id in number,
        p_rec_freq     varchar2
    ) return scheduler_t
        pipelined
        deterministic
    is
        l_record    scheduler_rec;
        l_next_date varchar2(20);
        l_processed number := 0;
    begin
        for x in (
            select
                to_char(period_date, 'MM/DD/YYYY') period_date
            from
                (
                    select
                        a.*,
                        rank()
                        over(
                            order by
                                period_date
                        ) as rank_date
                    from
                        scheduler_calendar a
                    where
                            a.schedule_id = p_scheduler_id
                        and period_date > sysdate
                )
            where
                rank_date = 1
        ) loop
            l_next_date := x.period_date;
        end loop;

        for x in (
            select
                a.scheduler_id,
                a.plan_type,
                pc_lookups.get_meaning(a.plan_type, 'FSA_PLAN_TYPE')   plan_type_meaning,
                a.recurring_flag,
                a.recurring_frequency,
                pc_lookups.get_payroll_frequncy(a.recurring_frequency) recurring_frequency_desc,
                to_char(payment_start_date, 'MM/DD/YYYY')              payment_start_date,
                to_char(payment_end_date, 'MM/DD/YYYY')                payment_end_date,
                a.amount,
                a.note,
                to_char(
                    max(p.plan_start_date),
                    'MM/DD/YYYY'
                )                                                      plan_start_date,
                a.reason_code                                          reason_code,
                a.bank_acct_id                                         bank_acct_id
            from
                scheduler_master          a,
                ben_plan_enrollment_setup p
            where
                    a.acc_id = p.acc_id (+)
                and a.plan_type = p.plan_type (+)
    --AND     A.PAYMENT_END_DATE = p.PLAN_END_DATE(+)
                and scheduler_id = p_scheduler_id
            group by
                a.scheduler_id,
                a.plan_type,
                pc_lookups.get_meaning(a.plan_type, 'FSA_PLAN_TYPE'),
                a.recurring_flag,
                a.recurring_frequency,
                pc_lookups.get_payroll_frequncy(a.recurring_frequency),
                to_char(payment_start_date, 'MM/DD/YYYY'),
                to_char(payment_end_date, 'MM/DD/YYYY'),
                a.amount,
                a.note,
                a.reason_code,
                a.bank_acct_id
        ) loop
            l_record.scheduler_id := x.scheduler_id;
            l_record.plan_type := x.plan_type;
            l_record.plan_type_desc := x.plan_type_meaning;
            l_record.recurring_flag := x.recurring_flag;
            l_record.recurring_freq := x.recurring_frequency;
            l_record.recurring_freq_desc := x.recurring_frequency_desc;
            l_record.payment_start_date := x.payment_start_date;
            l_record.payment_end_date := x.payment_end_date;
            l_record.plan_start_date := x.plan_start_date;
            l_record.plan_end_date := x.payment_end_date;
            l_record.next_process_date := l_next_date;
            l_record.total_amount := x.amount;
            l_record.note := x.note;
            l_record.reason_code := x.reason_code;
            l_record.contribution_type := pc_lookups.get_fee_reason(x.reason_code);
            l_record.bank_acct_id := x.bank_acct_id;
            if x.bank_acct_id is not null then
                for xx in (
                    select
                        display_name,
                        bank_acct_num
                    from
                        user_bank_acct
                    where
                        bank_acct_id = x.bank_acct_id
                ) loop
                    l_record.bank_name := xx.display_name;
                    l_record.bank_acct_num := xx.bank_acct_num;
                end loop;
            end if;

            pipe row ( l_record );
        end loop;

    end copy_schedule_detail;

-- Added by Joshi for #9968.(monthly frequency date change issue for HSA)
    function get_schedule_hsa (
        p_acc_id  in number,
        freq_code in varchar2,
        start_dt  date,
        end_dt    date
    ) return schedule_date_table as

        l_trans_dt         date;
        l_day              varchar2(10);
        l_biweek_day       varchar2(10);
        l_biweek_trans_dt  date;
        l_bimonthly_mid_dt date;
   --l_bimonthly_start_dt date;
        l_monthly_trans_dt date;
        l_trans_date_list  schedule_date_table;
        ctr                number := 1;
        month_ctr          number := 0;
        l_date_exist       boolean := false;
        i                  number;
    begin
        l_trans_dt := start_dt;
        if freq_code = 'SEMIMONTHLY1' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(trunc(start_dt, 'MM') + 14,
                                   k) period_date
                    from
                        data
                    union
                    select
                        add_months(
                            last_day(start_dt),
                            k
                        ) period_date
                    from
                        data
                    where
                        add_months(
                            last_day(start_dt),
                            k
                        ) > start_dt
                    order by
                        1
                )
            where
                    period_date >= start_dt
                and period_date <= end_dt;
		-- IF last day is 31, it should add date to pay dates.
            if start_dt = last_day(start_dt) then
                l_trans_date_list(l_trans_date_list.count + 1) := start_dt;
            end if;

        elsif freq_code = 'SEMIMONTHLY2' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(trunc(start_dt, 'MM') + 4,
                                   k) period_date
                    from
                        data
                    union
                    select
                        add_months(trunc(start_dt, 'MM') + 19,
                                   k) period_date
                    from
                        data
                    where
                        add_months(trunc(start_dt, 'MM') + 19,
                                   k) > start_dt
                    order by
                        1
                )
            where
                    period_date >= start_dt
                and period_date <= end_dt;

        elsif freq_code = 'BIWEEKLY' then
            with data as (
                select
                    2 * level k
                from
                    dual
                connect by
                    level <= 26
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(start_dt, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= end_dt;
        ----l_trans_date_list(l_trans_date_list.COUNT+1) := start_dt;  rprabu commented for franco email 12/12/2019
		----l_trans_date_list(l_trans_date_list.COUNT) := start_dt;      ----added by rprabu   for franco email 12/12/2019

         -- Added by Joshi for 10952
            for i in 1..l_trans_date_list.count loop
                if ( l_trans_date_list(i) = start_dt ) then
                    l_date_exist := true;
                end if;
            end loop;

            if l_date_exist = false then
                l_trans_date_list(l_trans_date_list.count + 1) := start_dt;
            end if;

        elsif freq_code = 'QUARTERLY' then
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        decode(rownum,
                               1,
                               start_dt,
                               add_months(start_dt, rownum * 3)) period_date
                    from
                        all_objects
                    where
                        rownum <= 4
                )
            where
                trunc(period_date) <= trunc(end_dt);

            if end_dt <> l_trans_date_list(l_trans_date_list.count) then
                l_trans_date_list(l_trans_date_list.count + 1) := end_dt;
            end if;

        elsif freq_code = 'MONTHLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 12
            )
            select
                *
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_months(start_dt, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= end_dt;

        elsif freq_code = 'WEEKLY' then
            with data as (
                select
                    level - 1 k
                from
                    dual
                connect by
                    level <= 52
            )
            select
                period_date period_date
            bulk collect
            into l_trans_date_list
            from
                (
                    select
                        add_weeks(start_dt, k) period_date
                    from
                        data
                    order by
                        1
                )
            where
                period_date <= end_dt;

        end if;

        return l_trans_date_list;
    end get_schedule_hsa;

-- Added by Jaggi #11365
    procedure upsert_scheduler_calender_stage (
        p_batch_number in number,
        p_paydates     in pc_online_enrollment.varchar2_tbl,
        p_user_id      number
    ) is
    begin
        delete scheduler_calendar_stage
        where
            batch_number = p_batch_number;

        for i in 1..p_paydates.count loop
            insert into scheduler_calendar_stage (
                batch_number,
                period_date,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( p_batch_number,
                       to_date(p_paydates(i),
                               'MM/DD/YYYY'),
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

        end loop;

    end;

    procedure insert_pay_date (
        p_batch_number in number,
        p_pay_date     varchar2
    ) is
    begin
        insert into scheduler_calendar_stage (
            batch_number,
            period_date
        )
            select
                p_batch_number,
                p_pay_date
            from
                dual;

    end;

    procedure delete_pay_date (
        p_batch_number in number,
        p_pay_date     varchar2
    ) is
    begin
        delete from scheduler_calendar_stage
        where
                batch_number = p_batch_number
            and period_date = p_pay_date;

    end;

    function get_employer_plan (
        p_acc_id          in number,
        p_plan_start_date in varchar2,
        p_plan_end_date   in varchar2
    ) return er_plan_detail_t
        pipelined
        deterministic
    is
        l_record er_plan_detail_rec;
    begin
        if trunc(to_date(p_plan_start_date, 'mm/dd/yyyy')) <= sysdate then
            for x in (
                select
                    plan_type,
                    plan_name,
                    trunc(to_date(plan_start_date, 'mm/dd/yyyy')) plan_start_date,
                    trunc(to_date(plan_end_date, 'mm/dd/yyyy'))   plan_end_date
                from
                    (
                        select
                            *
                        from
                            table ( pc_enroll_utility_pkg.get_enrolled_benefit_plan(p_acc_id, 'FSA') )
                        union
                        select
                            *
                        from
                            table ( pc_enroll_utility_pkg.get_enrolled_benefit_plan(p_acc_id, 'HRA') )
                        where
                            plan_type in ( 'HRP', 'HR5' )
                    )
                where
                        plan_start_date = nvl(p_plan_start_date, plan_start_date)
                    and plan_end_date = nvl(plan_end_date, plan_end_date)
                    and trunc(to_date(plan_start_date, 'mm/dd/yyyy')) <= sysdate
                    and trunc(to_date(plan_end_date, 'mm/dd/yyyy')) >= sysdate
            ) loop
                l_record.plan_name := x.plan_name;
                l_record.plan_type := x.plan_type;
                pipe row ( l_record );
            end loop;
        end if;

        if trunc(to_date(p_plan_start_date, 'mm/dd/yyyy')) > sysdate then
            for x in (
                select
                    plan_type,
                    plan_name,
                    trunc(to_date(plan_start_date, 'mm/dd/yyyy')) plan_start_date,
                    trunc(to_date(plan_end_date, 'mm/dd/yyyy'))   plan_end_date
                from
                    (
                        select
                            *
                        from
                            table ( pc_enroll_utility_pkg.get_enrolled_benefit_plan(p_acc_id, 'FSA') )
                        union
                        select
                            *
                        from
                            table ( pc_enroll_utility_pkg.get_enrolled_benefit_plan(p_acc_id, 'HRA') )
                        where
                            plan_type in ( 'HRP', 'HR5' )
                    )
                where
                        plan_start_date = nvl(p_plan_start_date, plan_start_date)
                    and plan_end_date = nvl(plan_end_date, plan_end_date)
                    and trunc(to_date(plan_start_date, 'mm/dd/yyyy')) > sysdate
                    and trunc(to_date(plan_end_date, 'mm/dd/yyyy')) >= sysdate
            ) loop
                l_record.plan_name := x.plan_name;
                l_record.plan_type := x.plan_type;
                pipe row ( l_record );
            end loop;

        end if;

    end get_employer_plan;

end pc_schedule;
/


-- sqlcl_snapshot {"hash":"021fc2423b48ed2af46ca2557b9a5f2a83e97de7","type":"PACKAGE_BODY","name":"PC_SCHEDULE","schemaName":"SAMQA","sxml":""}