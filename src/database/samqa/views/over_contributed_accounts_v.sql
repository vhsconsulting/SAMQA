create or replace force editionable view samqa.over_contributed_accounts_v (
    acc_id,
    acc_num,
    fedmax,
    balance,
    email_address
) as
    select
        acc_id,
        acc_num,
        trunc(fedmax + nvl((case
            when age >= 55 then
                pc_param.get_system_value('CATCHUP_CONTRIBUTION', sysdate) * nvl(prorate, 0)
            else 0
        end),
                           0))   fedmax,
        balance,
        email email_address
    from
        (
            select
                d.acc_id,
                d.acc_num,
                case
                    when plan_type = 0 then
                        pc_param.get_system_value('INDIVIDUAL_CONTRIBUTION', sysdate)
                    else
                        pc_param.get_system_value('FAMILY_CONTRIBUTION', sysdate)
                end                                             fedmax,
                b.start_date,
                c.email,
                trunc(months_between(sysdate, birth_date) / 12) age,
                nvl((
                    select
                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                    from
                        income
                    where
                            acc_id = d.acc_id
                        and trunc(fee_date) between trunc(sysdate, 'YEAR') and sysdate
                        and fee_code in(0, 3, 4, 6, 110)
                ) -(
                    select
                        sum(nvl(amount, 0))
                    from
                        payment
                    where
                            acc_id = d.acc_id
                        and trunc(pay_date) between trunc(sysdate, 'YEAR') and sysdate
                        and reason_code in(1, 2)
                    group by
                        acc_id,
                        plan_code
                ),
                    0) - ( 12 - (
                    select
                        count(*)
                    from
                        payment
                    where
                            acc_id = d.acc_id
                        and pay_date > greatest(d.start_date,
                                                trunc(sysdate, 'YEAR'))
                        and reason_code = 2
                ) ) * pc_plan.fmonth(d.plan_code)               balance,
                case
                    when to_char(b.start_date, 'YYYY') > to_char(sysdate, 'YYYY') then
                        0
                    else
                        1
                end                                             prorate
            from
                online_users         c,
                account              d,
                account_email_alerts e,
                person               a,
                insure               b
            where
                    c.find_key = acc_num
                and e.acc_id = d.acc_id
                and e.over_contribution = 'N'
                and a.pers_id = b.pers_id
                and a.pers_id = d.pers_id
                and d.account_status = 1
                and d.start_date < add_months(
                    trunc(sysdate, 'YEAR'),
                    12
                )
        )
    where
        balance > fedmax + nvl((case
            when age >= 55 then
                pc_param.get_system_value('CATCHUP_CONTRIBUTION', sysdate) * nvl(prorate, 0)
            else 0
        end),
                               0);


-- sqlcl_snapshot {"hash":"0f74185d2fd2cdf40577d20c43478c04d48450b0","type":"VIEW","name":"OVER_CONTRIBUTED_ACCOUNTS_V","schemaName":"SAMQA","sxml":""}