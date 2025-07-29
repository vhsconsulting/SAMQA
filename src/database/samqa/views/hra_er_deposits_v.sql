create or replace force editionable view samqa.hra_er_deposits_v (
    list_bill,
    check_date,
    aco_amt,
    hrp_amt,
    hr5_amt,
    hra_amt,
    hr4_amt,
    acc_num,
    account_type
) as
    select
        list_bill,
        check_date,
        sum(
            case
                when plan_type = 'ACO' then
                    check_amount
                else
                    0
            end
        ) aco_amt,
        sum(
            case
                when plan_type = 'HRP' then
                    check_amount
                else
                    0
            end
        ) hrp_amt,
        sum(
            case
                when plan_type = 'HR5' then
                    check_amount
                else
                    0
            end
        ) hr5_amt,
        sum(
            case
                when plan_type = 'HRA' then
                    check_amount
                else
                    0
            end
        ) hra_amt,
        sum(
            case
                when plan_type = 'HR4' then
                    check_amount
                else
                    0
            end
        ) hr4_amt,
        acc_num,
        account_type
    from
        employer_deposits_v
    where
        nvl(reason_code, 4) <> 40
    group by
        list_bill,
        check_date,
        acc_num,
        account_type;


-- sqlcl_snapshot {"hash":"c5bb8e29bf898f6ef7baacc699be5eb153fa3ab8","type":"VIEW","name":"HRA_ER_DEPOSITS_V","schemaName":"SAMQA","sxml":""}