create or replace force editionable view samqa.fsa_new_enrollments_v (
    enrollment_type,
    ryear,
    rmonth,
    rmm,
    dependantcare,
    healthcare,
    transit,
    parking,
    ind_ins_premium,
    limited_purpose,
    bicycle,
    total_acc
) as
    with enrollments as (
        select
            greatest(creation_date, effective_date) effective_date,
            acc_id,
            plan_end_date,
            effective_end_date,
            plan_type,
            (
                select
                    count(*)
                from
                    ben_plan_enrollment_setup a
                where
                        a.acc_id = b.acc_id
                    and a.plan_type = b.plan_type
                    and a.status <> 'R'
                    and a.plan_type not in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
                group by
                    acc_id,
                    plan_type
            )                                       no_of_plans
        from
            ben_plan_enrollment_setup b
        where
            plan_type not in ( 'HRA', 'HR5', 'HR4', 'HRP', 'ACO' )
            and entrp_id is null
            and status <> 'R'
            and ben_plan_id_main is not null
    )
    select
        enrollment_type,
        ryear,
        rmonth,
        rmm,
        sum(decode(plan_type, 'DCA', no_of_acc, 0)) dependantcare,
        sum(decode(plan_type, 'FSA', no_of_acc, 0)) healthcare,
        sum(decode(plan_type, 'TRN', no_of_acc, 0)) transit,
        sum(decode(plan_type, 'PKG', no_of_acc, 0)) parking,
        sum(decode(plan_type, 'IIR', no_of_acc, 0)) ind_ins_premium,
        sum(decode(plan_type, 'LPF', no_of_acc, 0)) limited_purpose,
        sum(decode(plan_type, 'UA1', no_of_acc, 0)) bicycle,
        sum(no_of_acc)                              total_acc
    from
        (
            select
                count(acc_id)                   no_of_acc,
                'RENEWAL'                       enrollment_type,
                plan_type,
                to_char(effective_date, 'YYYY') ryear,
                to_char(effective_date, 'MON')  rmonth,
                to_char(effective_date, 'MM')   rmm
            from
                enrollments
            where
                no_of_plans > 1
            group by
                'RENEWAL',
                plan_type,
                to_char(effective_date, 'YYYY'),
                to_char(effective_date, 'MON'),
                to_char(effective_date, 'MM')
            union
            select
                count(acc_id),
                'NEW',
                plan_type,
                to_char(effective_date, 'YYYY') ryear,
                to_char(effective_date, 'MON')  rmonth,
                to_char(effective_date, 'MM')   rmm
            from
                enrollments
            where
                no_of_plans = 1
            group by
                plan_type,
                to_char(effective_date, 'YYYY'),
                to_char(effective_date, 'MON'),
                to_char(effective_date, 'MM')
            union all
            select
                - count(acc_id),
                'TERMINATED',
                plan_type,
                to_char(effective_end_date, 'YYYY') ryear,
                to_char(effective_end_date, 'MON')  rmonth,
                to_char(effective_end_date, 'MM')   rmm
            from
                enrollments
            where
                    effective_end_date <= trunc(sysdate)
                and plan_end_date > effective_end_date
            group by
                plan_type,
                to_char(effective_end_date, 'YYYY'),
                to_char(effective_end_date, 'MON'),
                to_char(effective_end_date, 'MM')
            union all
            select
                - count(acc_id),
                'TERMINATED PLANS',
                plan_type,
                to_char(plan_end_date, 'YYYY') ryear,
                to_char(plan_end_date, 'MON')  rmonth,
                to_char(plan_end_date, 'MM')   rmm
            from
                enrollments
            where
                    plan_end_date < sysdate
                and effective_end_date is null
            group by
                plan_type,
                to_char(plan_end_date, 'YYYY'),
                to_char(plan_end_date, 'MON'),
                to_char(plan_end_date, 'MM')
        )
    group by
        enrollment_type,
        ryear,
        rmonth,
        rmm
    order by
        2,
        4;


-- sqlcl_snapshot {"hash":"0ccc5335325adeb2ced7db5a25824145627fdcb9","type":"VIEW","name":"FSA_NEW_ENROLLMENTS_V","schemaName":"SAMQA","sxml":""}