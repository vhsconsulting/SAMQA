-- liquibase formatted sql
-- changeset SAMQA:1754374175341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\hra_enrollments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/hra_enrollments_v.sql:null:3a445f2af100086f8bee875ee962f700981d4d9d:create

create or replace force editionable view samqa.hra_enrollments_v (
    active,
    renewal,
    terminated,
    ryear,
    rmonth,
    rmm
) as
    with enrollments as (
        select
            effective_date,
            acc_id,
            plan_end_date,
            effective_end_date,
            (
                select
                    count(*)
                from
                    ben_plan_enrollment_setup a
                where
                        a.acc_id = b.acc_id
                    and a.plan_type = b.plan_type
                    and a.status in ( 'A', 'I' )
                    and a.plan_type in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
                group by
                    acc_id,
                    plan_type
            ) no_of_plans
        from
            ben_plan_enrollment_setup b
        where
            plan_type in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
            and b.status in ( 'A', 'I' )
    --AND     TRUNC(PLAN_END_DATE) > SYSDATE
    --AND     (EFFECTIVE_END_DATE IS NULL OR TRUNC(EFFECTIVE_END_DATE) > SYSDATE)
            and ben_plan_id_main is not null
            and entrp_id is null
    )
    select
        sum(decode(enrollment_type, 'NEW', no_of_acc, 0))        active,
        sum(decode(enrollment_type, 'RENEWAL', no_of_acc, 0))    renewal,
        sum(decode(enrollment_type, 'TERMINATED', no_of_acc, 0)) terminated,
        ryear,
        rmonth,
        rmm
    from
        (
            select
                count(acc_id)                   no_of_acc,
                'RENEWAL'                       enrollment_type,
                to_char(effective_date, 'YYYY') ryear,
                to_char(effective_date, 'MON')  rmonth,
                to_char(effective_date, 'MM')   rmm
            from
                enrollments
            where
                    no_of_plans > 1
                and trunc(plan_end_date) > sysdate
                and ( effective_end_date is null
                      or trunc(effective_end_date) > sysdate )
            group by
                'RENEWAL',
                to_char(effective_date, 'YYYY'),
                to_char(effective_date, 'MON'),
                to_char(effective_date, 'MM')
            union
            select
                count(acc_id),
                'NEW',
                to_char(effective_date, 'YYYY') ryear,
                to_char(effective_date, 'MON')  rmonth,
                to_char(effective_date, 'MM')   rmm
            from
                enrollments
            where
                    no_of_plans = 1
                and trunc(plan_end_date) > sysdate
                and ( effective_end_date is null
                      or trunc(effective_end_date) > sysdate )
            group by
                to_char(effective_date, 'YYYY'),
                to_char(effective_date, 'MON'),
                to_char(effective_date, 'MM')
            union
            select
                count(acc_id),
                'TERMINATED',
                to_char(effective_end_date, 'YYYY') ryear,
                to_char(effective_end_date, 'MON')  rmonth,
                to_char(effective_end_date, 'MM')   rmm
            from
                enrollments
            where
                    no_of_plans = 1
                and trunc(effective_end_date) < sysdate
            group by
                to_char(effective_end_date, 'YYYY'),
                to_char(effective_end_date, 'MON'),
                to_char(effective_end_date, 'MM')
            union
            select
                count(acc_id),
                'TERMINATED',
                to_char(plan_end_date, 'YYYY') ryear,
                to_char(plan_end_date, 'MON')  rmonth,
                to_char(plan_end_date, 'MM')   rmm
            from
                enrollments
            where
                    no_of_plans = 1
                and trunc(plan_end_date) < sysdate
            group by
                to_char(plan_end_date, 'YYYY'),
                to_char(plan_end_date, 'MON'),
                to_char(plan_end_date, 'MM')
        )
    group by
        ryear,
        rmonth,
        rmm
    order by
        4,
        6;

