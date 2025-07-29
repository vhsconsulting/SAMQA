create or replace force editionable view samqa.taxform_5498_v (
    account_number,
    name,
    address,
    city,
    state,
    zip,
    ssn,
    box1,
    box2,
    box3,
    box4,
    box5,
    box6
) as
    select
        account_number,
        name,
        address,
        city,
        state,
        zip,
        ssn,
        0   box1,
        box2,
        box3,
        box4,
        case
            when box5 < 0 then
                0
            else
                box5
        end box5,
        'Y' box6
    from
        (
            select
                account_number,
                name,
                address,
                city,
                state,
                zip,
                ssn,
                0                                                box1,
                deposit + catchup + prevyear - acc_maint         box2,
                taxyear                                          box3,
                rollover                                         box4,
                pc_account.current_balance(account_id,
                                           '01-JAN-2004',
                                           round(sysdate, 'YYYY') - 1) + outside box5,
                'Y'
            from
                (
                    select
                        replace(u_name, ',', ' ')                                            name,
                        address,
                        city,
                        state,
                        zip,
                        ssn,
                        acc_num                                                              account_number,
                        acc_id                                                               account_id,
                        age                                                                  age,
                        decode(coverage, 'F', 'Family Coverage', 'I', 'Individual Coverage') coverage,
                        deductible,
                        decode(coverage,
                               'F',
                               pc_param.get_system_value('FAMILY_CONTRIBUTION',
                                                         round(sysdate, 'YYYY') - 1),
                               'I',
                               pc_param.get_system_value('INDIVIDUAL_CONTRIBUTION',
                                                         round(sysdate, 'YYYY') - 1))                         fed_max,
                        case
                            when age >= 55 then
                                pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                          round(sysdate, 'YYYY') - 1)
                            else
                                '0'
                        end                                                                  catchup_contribution,
                        start_date,
                        case
                            when to_number(to_char(start_date, 'YYYY')) < to_number(to_char(round(sysdate, 'YYYY') - 1,
                                                                                            'YYYY')) then
                                1
                            when to_number(to_char(start_date, 'YYYY')) = to_number(to_char(round(sysdate, 'YYYY') - 1,
                                                                                            'YYYY')) then
                                ( 13 - to_number(to_char(start_date, 'MM')) ) / 12
                        end                                                                  proration,
                        nvl(deposit, 0)                                                      deposit,
                        nvl(rollover, 0)                                                     rollover,
                        nvl(taxyear, 0)                                                      taxyear,
                        nvl(disbursement, 0)                                                 disbursement,
                        nvl(account_fees, 0)                                                 account_fees,
                        nvl(acc_maint, 0)                                                    acc_maint,
                        nvl(outside, 0)                                                      outside,
                        nvl(catchup, 0)                                                      catchup,
                        nvl(prevyear, 0)                                                     prevyear
                    from
                        (
                            select
                                person.first_name
                                || ' '
                                || person.middle_name
                                || ' '
                                || person.last_name                                    u_name,
                                person.address                                         address,
                                person.city,
                                person.state,
                                person.zip,
                                person.ssn,
                                l_acc.acc_num                                          acc_num,
                                l_acc.acc_id,
                                person.birth_date                                      birth_date,
                                round(months_between(sysdate, person.birth_date) / 12) age,
                                case
                                    when (
                                        select
                                            count(pers_main)
                                        from
                                            person a
                                        where
                                            a.pers_main = person.pers_id
                                    ) > 0 then
                                        'F'
                                    else
                                        'I'
                                end                                                    coverage,
                                insure.deductible,
                                insure.start_date,
                                nvl(deposit, 0)                                        deposit,
                                nvl(rollover, 0)                                       rollover,
                                nvl(catchup, 0)                                        catchup,
                                nvl(prevyear, 0)                                       prevyear,
                                (
                                    select
                                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                                    from
                                        income
                                    where
                                        fee_code in ( 7, 10 )
                                        and acc_id = l_acc.acc_id
                                        and fee_date between round(sysdate, 'YYYY') and round(sysdate, 'YYYY') + 118
                                )                                                      taxyear,
                                invest.out_inv                                         outside,
                                pay.acc_maint,
                                pay.account_fees,
                                pay.disbursement
                            from
                                person  person,
                                insure,
                                account l_acc,
                                (
                                    select
                                        acc_id,
                                        sum(nvl(deposit, 0))  deposit,
                                        sum(nvl(catchup, 0))  catchup,
                                        sum(nvl(rollover, 0)) rollover,
                                        sum(nvl(prevyear, 0)) prevyear
                                    from
                                        (
                                            select
                                                acc_id,
                                                nvl(
                                                    decode(
                                                        nvl(fee_code, 3),
                                                        3,
                                                        sum(nvl(amount, 0) + nvl(amount_add, 0))
                                                    ),
                                                    0
                                                ) + nvl(
                                                    decode(fee_code,
                                                           4,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(fee_code,
                                                           0,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) deposit,
                                                nvl(
                                                    decode(fee_code,
                                                           5,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) rollover,
                                                nvl(
                                                    decode(fee_code,
                                                           6,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) catchup,
                                                nvl(
                                                    decode(fee_code,
                                                           7,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(fee_code,
                                                           10,
                                                           sum(nvl(amount, 0) + nvl(amount_add, 0))),
                                                    0
                                                ) prevyear
                                            from
                                                income
                                            where
                                                ( fee_code is null
                                                  or fee_code in ( 3, 4, 5, 6, 7 ) )
                                                and fee_date between trunc((round(sysdate, 'YYYY') - 1),
                                                                           'YYYY') and round(sysdate, 'YYYY') - 1
                                            group by
                                                acc_id,
                                                contributor,
                                                fee_code
                                        )
                                    group by
                                        acc_id
                                )       acc,
                                (
                                    select
                                        acc_id,
                                        sum(nvl(account_fees, 0)) account_fees,
                                        sum(nvl(disbursement, 0)) disbursement,
                                        sum(nvl(acc_maint, 0))    acc_maint
                                    from
                                        (
                                            select
                                                acc_id,
                                                nvl(
                                                    decode(reason_code,
                                                           1,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           2,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           15,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           17,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) account_fees,
                                                nvl(
                                                    decode(reason_code,
                                                           1,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           2,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) acc_maint,
                                                nvl(
                                                    decode(reason_code,
                                                           16,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           19,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           0,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           11,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           12,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           13,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           14,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) + nvl(
                                                    decode(reason_code,
                                                           18,
                                                           sum(nvl(amount, 0))),
                                                    0
                                                ) disbursement
                                            from
                                                payment
                                            where
                                                pay_date between trunc((round(sysdate, 'YYYY') - 1),
                                                                       'YYYY') and round(sysdate, 'YYYY') - 1
                                            group by
                                                acc_id,
                                                reason_code
                                        )
                                    group by
                                        acc_id
                                )       pay,
                                (
                                    select
                                        invest_transfer.invest_amount out_inv,
                                        acc_id
                                    from
                                        investment      invest,
                                        invest_transfer invest_transfer
                                    where
                                            invest_transfer.investment_id = invest.investment_id
                                        and invest_date = round(sysdate, 'YYYY') - 1
                                )       invest
                            where
                                    insure.pers_id = person.pers_id
                                and insure.start_date < round(sysdate, 'YYYY')
                                and l_acc.account_type = 'HSA'
                                and l_acc.pers_id = person.pers_id (+)
                                and l_acc.acc_id = acc.acc_id (+)
                                and l_acc.acc_id = invest.acc_id (+)
                                and l_acc.acc_id = pay.acc_id (+)
                        )
                )
        )
    where
        box2 > 0;


-- sqlcl_snapshot {"hash":"f3815c9b48357ebb71a2f903008a13422453c2da","type":"VIEW","name":"TAXFORM_5498_V","schemaName":"SAMQA","sxml":""}