create or replace function samqa.get_er_interest (
    dat_from in date default sysdate - 31,
    dat_to   in date default sysdate,
    entrp_in in number default null  -- NULL means all accounts
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
        get_employer_balance(entrp_in, transaction_date, plan_type) balance
    from
        employer_balances_v a,
        account             b
    where
            a.entrp_id = entrp_in
        and a.entrp_id = b.entrp_id
        and a.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' )
        and b.account_type = 'HRA'
        and trunc(transaction_date) >= dat_from
        and trunc(transaction_date) <= dat_to
    union all
    select
        a.entrp_id,
        0,
        dat_to,
        'Interest',
        get_employer_balance(entrp_in, to_date('31-OCT-2011'), d.plan_type)
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
        and d.plan_start_date <= sysdate
        and d.plan_end_date >= trunc(sysdate)
        and dd between d.plan_start_date and last_day(least(
            nvl(d.effective_end_date, d.plan_end_date),
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
/


-- sqlcl_snapshot {"hash":"9675ffaf6763ce827ca742af3289d7959c4221ea","type":"FUNCTION","name":"GET_ER_INTEREST","schemaName":"SAMQA","sxml":""}