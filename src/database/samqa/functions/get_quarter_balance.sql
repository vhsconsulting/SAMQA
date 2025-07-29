create or replace function samqa.get_quarter_balance (
    p_acc_id      in number,
    p_plan_type   in varchar2,
    p_start_date  in date,
    p_end_date    in date,
    p_ben_plan_id in number
) return number is
    l_total  number;
    l_exists varchar2(1) := 'N';
begin
    dbms_output.put_line('balance '
                         || l_total
                         || ' plan type '
                         || p_plan_type);
    l_exists := 'N';
    for x in (
        select
            c.annual_election,
            b.account_status,
            sum(
                case
                    when c.plan_type in('HRA', 'LPF', 'FSA') then
                        decode(a.reason_mode, 'I', 0, amount)
                    else
                        amount
                end
            ) amount,
            c.ben_plan_id
        from
            balance_register          a,
            account                   b,
            ben_plan_enrollment_setup c
        where
                a.acc_id = p_acc_id
            and b.account_type in ( 'HRA', 'FSA' )
            and a.acc_id = b.acc_id
            and c.acc_id = b.acc_id
            and c.plan_type = a.plan_type
            and c.plan_type = p_plan_type
            and c.ben_plan_id = p_ben_plan_id
            and trunc(c.plan_start_date) <= trunc(p_start_date)
                 --     AND  TRUNC(c.plan_end_date)   >= nvl(TRUNC(P_END_DATE) ,TRUNC(c.plan_end_date))
            and nvl(c.effective_end_date, p_end_date) + nvl(c.runout_period_days, 0) >= p_end_date
            and trunc(fee_date) >= trunc(c.plan_start_date)
            and trunc(c.plan_end_date) + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0) >= trunc(sysdate)
            and trunc(fee_date) >= nvl(
                trunc(p_start_date),
                trunc(c.plan_start_date)
            )
            and trunc(fee_date) <= decode(a.reason_mode,
                                          'EP',
                                          nvl(
                                                   trunc(p_end_date),
                                                   trunc(sysdate)
                                               ) + 3,
                                          nvl(
                                                   trunc(p_end_date),
                                                   trunc(sysdate)
                                               ))
        group by
            c.annual_election,
            b.account_status,
            c.ben_plan_id
    ) loop
        l_exists := 'Y';
        if p_plan_type in ( 'HRA', 'FSA', 'LPF' ) then
            l_total := x.annual_election + x.amount;
        else
            l_total := x.amount;
        end if;

        dbms_output.put_line('balance ' || l_total);
    end loop;

    dbms_output.put_line('balance '
                         || l_total
                         || ' plan type '
                         || p_plan_type);
    if
        p_plan_type in ( 'HRA', 'LPF', 'FSA' )
        and l_exists = 'N'
        and nvl(l_total, 0) = 0
    then
        for x in (
            select
                b.account_status,
                c.annual_election amount
            from
                account                   b,
                ben_plan_enrollment_setup c
            where
                    b.acc_id = p_acc_id
                and b.account_type in ( 'HRA', 'FSA' )
                and c.acc_id = b.acc_id
                and c.plan_type = p_plan_type
                and c.plan_type in ( 'HRA', 'LPF', 'FSA' )
                and nvl(c.effective_end_date, p_end_date) + nvl(c.runout_period_days, 0) >= p_end_date
                and trunc(c.plan_start_date) <= trunc(p_start_date)
                and trunc(c.plan_end_date) + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0) >= trunc(p_end_date)
        ) loop
            l_total := x.amount;
        end loop;
    end if;

    return nvl(l_total, 0);
end get_quarter_balance;
/


-- sqlcl_snapshot {"hash":"909bd1ec6b705ee796f28eb56fa161d8e38c98d2","type":"FUNCTION","name":"GET_QUARTER_BALANCE","schemaName":"SAMQA","sxml":""}