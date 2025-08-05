-- liquibase formatted sql
-- changeset SAMQA:1754374172055 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\emp_contributions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/emp_contributions_v.sql:null:e5c7b0ef9714f14e8db161cf2b24154390496177:create

create or replace force editionable view samqa.emp_contributions_v (
    contributor,
    fee_mm,
    fee_month,
    emp_deposit,
    subscr_deposit,
    ee_fee_deposit,
    er_fee_deposit
) as
    select
        contributor,
        to_char(fee_date, 'MM')       fee_mm,
        to_char(fee_date, 'MON-YYYY') fee_month,
        sum(nvl(amount, 0))           emp_deposit,
        sum(nvl(amount_add, 0))       subscr_deposit,
        sum(nvl(ee_fee_amount, 0))    ee_fee_deposit,
        sum(nvl(er_fee_amount, 0))    er_fee_deposit
    from
        income
    where
        fee_date > trunc(sysdate, 'YYYY')
    group by
        contributor,
        to_char(fee_date, 'MON-YYYY'),
        to_char(fee_date, 'MM');

