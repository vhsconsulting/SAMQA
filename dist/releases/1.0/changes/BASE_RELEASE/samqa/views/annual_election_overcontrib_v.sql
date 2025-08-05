-- liquibase formatted sql
-- changeset SAMQA:1754374168129 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\annual_election_overcontrib_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/annual_election_overcontrib_v.sql:null:8353ba5874694d18807dff0ae25cf0a551493102:create

create or replace force editionable view samqa.annual_election_overcontrib_v (
    first_name,
    last_name,
    er_name,
    acc_num,
    plan_start_date,
    plan_end_date,
    plan_type,
    annual_election,
    total_receipt,
    ben_plan_id_main
) as
    select
        p.first_name,
        p.last_name,
        pc_entrp.get_entrp_name(b.entrp_id) er_name,
        d.acc_num,
        b.plan_start_date,
        b.plan_end_date,
        b.plan_type,
        b.annual_election,
        sum(a.amount + a.amount_add)        total_receipt,
        b.ben_plan_id_main
    from
        income                    a,
        ben_plan_enrollment_setup b,
        account                   d,
        person                    p
    where
            a.acc_id = b.acc_id
        and a.fee_code = 11
        and d.acc_id = b.acc_id
        and p.pers_id = d.pers_id
        and a.fee_date between b.plan_start_date and b.plan_end_date
        and a.plan_type = b.plan_type
    group by
        p.first_name,
        p.last_name,
        pc_entrp.get_entrp_name(b.entrp_id),
        d.acc_num,
        b.plan_start_date,
        b.plan_end_date,
        b.plan_type,
        b.annual_election,
        b.ben_plan_id_main
    having
        sum(a.amount + a.amount_add) > b.annual_election;

