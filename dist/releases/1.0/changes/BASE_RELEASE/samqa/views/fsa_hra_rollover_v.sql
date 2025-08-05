-- liquibase formatted sql
-- changeset SAMQA:1754374174525 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_hra_rollover_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_hra_rollover_v.sql:null:60ca8998d6052311fb95cdfbab3b0628373d1cbb:create

create or replace force editionable view samqa.fsa_hra_rollover_v (
    first_name,
    last_name,
    acc_num,
    plan_start_date,
    plan_end_date,
    plan_type,
    rollover_amount,
    max_rollover_amount,
    acc_balance,
    entrp_id,
    termination_date,
    ben_plan_id_main
) as
    select
        first_name,
        last_name,
        acc_num,
        a.plan_start_date,
        a.plan_end_date,
        a.plan_type,
        case
            when termination_date <= plan_end_date then
                0
            else
                decode(max_rollover_amount,
                       0,
                       acc_balance,
                       least(max_rollover_amount, acc_balance))
        end rollover_amount,
        max_rollover_amount,
        a.acc_balance,
        a.entrp_id,
        termination_date,
        ben_plan_id_main
    from
        fsa_hra_employees_v a,
        ben_plan_coverages  b
    where
            a.ben_plan_id = b.ben_plan_id
        and ltrim(rtrim(a.plan_type)) in ( 'HRA', 'HRP', 'HR5', 'ACO', 'LPF',
                                           'FSA' )
        and a.acc_id not in (
            select
                b.acc_id
            from
                scheduler_master  c, scheduler_details d
            where
                    c.scheduler_id = d.scheduler_id
                and c.orig_system_ref = a.ben_plan_id_main
        )
        and exists (
            select
                *
            from
                ben_plan_enrollment_setup c
            where
                    c.acc_id = a.acc_id
                and plan_end_date > sysdate
                and status <> 'P'
                and a.plan_type = c.plan_type
        );

