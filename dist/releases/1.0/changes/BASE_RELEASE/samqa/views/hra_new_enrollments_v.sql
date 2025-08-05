-- liquibase formatted sql
-- changeset SAMQA:1754374175509 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\hra_new_enrollments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/hra_new_enrollments_v.sql:null:664746289beec3df795e552f96b120b2e17ebcb6:create

create or replace force editionable view samqa.hra_new_enrollments_v (
    enrollment_type,
    ryear,
    rmonth,
    rmm,
    no_of_acc
) as
    with enrollments as (
        select
            greatest(creation_date, effective_date) effective_date,
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
                    and a.plan_type in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
                    and a.status in ( 'A', 'I' )
                group by
                    acc_id,
                    plan_type
            )                                       no_of_plans
        from
            ben_plan_enrollment_setup b
        where
            plan_type in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
            and entrp_id is null
            and b.status in ( 'A', 'I' )
            and ben_plan_id_main is not null
    )
    select
        enrollment_type,
        ryear,
        rmonth,
        rmm,
        sum(no_of_acc) total_acc
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
            group by
                to_char(effective_date, 'YYYY'),
                to_char(effective_date, 'MON'),
                to_char(effective_date, 'MM')
            union all
            select
                - count(acc_id),
                'TERMINATED',
                to_char(effective_end_date, 'YYYY') ryear,
                to_char(effective_end_date, 'MON')  rmonth,
                to_char(effective_end_date, 'MM')   rmm
            from
                enrollments
            group by
                to_char(effective_end_date, 'YYYY'),
                to_char(effective_end_date, 'MON'),
                to_char(effective_end_date, 'MM')
        )
    group by
        enrollment_type,
        ryear,
        rmonth,
        rmm
    order by
        2,
        4;

