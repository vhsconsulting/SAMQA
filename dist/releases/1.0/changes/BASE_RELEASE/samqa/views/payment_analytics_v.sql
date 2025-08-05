-- liquibase formatted sql
-- changeset SAMQA:1754374177888 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\payment_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/payment_analytics_v.sql:null:a9a2bfc5f32b4e34576f127a71795eb648908cf6:create

create or replace force editionable view samqa.payment_analytics_v (
    pay_date,
    amount,
    reason_name,
    employer_name,
    er_acc_num
) as
    select
        to_char(p.pay_date, 'MM/YYYY')      pay_date,
        sum(nvl(p.amount, 0))               amount,
        pr.reason_name,
        pc_entrp.get_entrp_name(p.entrp_id) employer_name,
        pc_entrp.get_acc_num(p.entrp_id)    er_acc_num
    from
        payment    p,
        account    ac,
        person     p,
        pay_reason pr
    where
            p.acc_id = ac.acc_id
        and ac.account_type = 'HSA'
        and p.pers_id = ac.pers_id
        and pr.reason_code = p.reason_code
        and pr.reason_type = 'FEE'
    group by
        to_char(p.pay_date, 'MM/YYYY'),
        pr.reason_name,
        p.entrp_id,
        p.entrp_id;

