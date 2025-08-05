-- liquibase formatted sql
-- changeset SAMQA:1754374176233 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\income_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/income_analytics_v.sql:null:55a85d068cd094c568be891c10576f1b092b812a:create

create or replace force editionable view samqa.income_analytics_v (
    fee_date,
    er_contribution,
    ee_contribution,
    ee_fee_amount,
    er_fee_amount,
    contributed_employer,
    reason_name,
    employer_name,
    er_acc_num
) as
    select
        to_char(p.fee_date, 'MM/YYYY')        fee_date,
        sum(nvl(p.amount, 0))                 er_contribution,
        sum(nvl(p.amount_add, 0))             ee_contribution,
        sum(nvl(p.ee_fee_amount, 0))          ee_fee_amount,
        sum(nvl(p.er_fee_amount, 0))          er_fee_amount,
        pc_entrp.get_acc_num(p.contributor)   contributed_employer,
        pc_lookups.get_fee_reason(p.fee_code) reason_name,
        pc_entrp.get_entrp_name(p.entrp_id)   employer_name,
        pc_entrp.get_acc_num(p.entrp_id)      er_acc_num
    from
        income  p,
        account ac,
        person  p
    where
            p.acc_id = ac.acc_id
        and ac.account_type = 'HSA'
        and p.pers_id = ac.pers_id
    group by
        to_char(p.fee_date, 'MM/YYYY'),
        p.entrp_id,
        p.fee_code,
        p.contributor;

