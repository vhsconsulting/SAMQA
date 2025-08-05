-- liquibase formatted sql
-- changeset SAMQA:1754374166464 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\acc_contributions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/acc_contributions_v.sql:null:8ee5d52bb43bf960918406c416a443d0009114db:create

create or replace force editionable view samqa.acc_contributions_v (
    acc_id,
    fee_month,
    fee_mm,
    emp_deposit,
    subscr_deposit,
    ee_fee_deposit,
    er_fee_deposit
) as
    select
        acc_id,
        to_char(fee_date, 'MON-YYYY') fee_month,
        to_char(fee_date, 'MM')       fee_mm,
        sum(nvl(amount, 0))           emp_deposit,
        sum(nvl(amount_add, 0))       subscr_deposit,
        sum(nvl(ee_fee_amount, 0))    ee_fee_deposit,
        sum(nvl(er_fee_amount, 0))    er_fee_deposit
    from
        income
    where
            trunc(fee_date) >= trunc(sysdate, 'YYYY')
        and nvl(fee_code, -1) <> 8
    group by
        acc_id,
        to_char(fee_date, 'MON-YYYY'),
        to_char(fee_date, 'MM');

