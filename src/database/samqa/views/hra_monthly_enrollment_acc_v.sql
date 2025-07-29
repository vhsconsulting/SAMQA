create or replace force editionable view samqa.hra_monthly_enrollment_acc_v (
    acc_year,
    acc_month,
    mm,
    active,
    continuing,
    total
) as
    select
        acc_year,
        acc_month,
        mm,
        sum(active)                   active,
        sum(continuing)               continuing,
        sum(active) + sum(continuing) total
    from
        (
            select
                to_char(reg_date, 'YYYY') acc_year,
                to_char(reg_date, 'MON')  acc_month,
                to_char(reg_date, 'MM')   mm,
                count(*)                  active,
                0                         continuing
            from
                account a,
                plans   b
            where
                a.pers_id is not null
                and a.plan_code = b.plan_code
                and b.plan_sign = 'SHA'
      --AND    PLAN_CODE IN (1,2,3)
                and a.account_status <> 5
                and a.account_type = 'HRA'
            group by
                to_char(reg_date, 'YYYY'),
                to_char(reg_date, 'MON'),
                to_char(reg_date, 'MM')
            union
            select
                to_char(b.plan_start_date, 'YYYY') year,
                to_char(b.plan_start_date, 'MON')  month,
                to_char(b.plan_start_date, 'MM')   mm,
                0                                  active,
                count(distinct b.acc_id)
            from
                ben_plan_enrollment_setup b,
                ben_plan_enrollment_setup c,
                account                   a
            where
                    a.acc_id = b.acc_id
                and c.acc_id = b.acc_id
                and a.account_type = 'HRA'
                and b.entrp_id is null
                and a.entrp_id is null
                and b.status <> 'R'
                and c.status <> 'R'
                and c.plan_type = b.plan_type
                and b.plan_start_date > c.plan_start_date
            group by
                to_char(b.plan_start_date, 'YYYY'),
                to_char(b.plan_start_date, 'MON'),
                to_char(b.plan_start_date, 'MM')
            order by
                1,
                3
        )
    group by
        acc_year,
        acc_month,
        mm;


-- sqlcl_snapshot {"hash":"4663e2cb6c37e634aea61a138e0350cba8881d0b","type":"VIEW","name":"HRA_MONTHLY_ENROLLMENT_ACC_V","schemaName":"SAMQA","sxml":""}