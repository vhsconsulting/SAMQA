-- liquibase formatted sql
-- changeset SAMQA:1754374178302 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\pop_comprehensive_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/pop_comprehensive_v.sql:null:b7aa474c2a61a73c450e96751abf28d0c1be0256:create

create or replace force editionable view samqa.pop_comprehensive_v (
    name,
    acc_num,
    plan_type,
    plan_start_date,
    plan_end_date,
    last_invoiced_date,
    last_payment_date
) as
    select
        pc_entrp.get_entrp_name(a.entrp_id) name,
        a.acc_num,
        b.plan_type,
        max(b.plan_start_date)              plan_start_date,
        max(b.plan_end_date)                plan_end_date,
        (
            select
                max(last_invoiced_date)
            from
                invoice_parameters
            where
                entity_id = a.entrp_id
        )                                   last_invoiced_date,
        (
            select
                max(transaction_date)
            from
                employer_payments
            where
                entrp_id = a.entrp_id
        )                                   last_payment_date
    from
        account                   a,
        ben_plan_enrollment_setup b
    where
            plan_code = 512
        and a.acc_id = b.acc_id
        and b.plan_type = 'NDT'
        and a.end_date is null
    group by
        a.acc_num,
        b.plan_type,
        a.entrp_id
    order by
        max(b.plan_start_date);

