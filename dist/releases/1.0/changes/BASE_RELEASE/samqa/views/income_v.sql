-- liquibase formatted sql
-- changeset SAMQA:1754374176304 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\income_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/income_v.sql:null:5a04dca390a7ba6208db20244f8d6e5551d291bb:create

create or replace force editionable view samqa.income_v (
    change_num,
    acc_id,
    fee_date,
    fee_code,
    amount,
    fee_amount,
    contributor,
    pay_code,
    cc_number,
    cc_code,
    cc_owner,
    cc_date,
    note
) as
    select
        change_num,
        acc_id,
        fee_date,
        decode(transaction_type, 'P', 110, fee_code)  fee_code,
        nvl(amount, 0) + nvl(amount_add, 0)           amount,
        nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) fee_amount,
        contributor,
        pay_code,
        cc_number,
        cc_code,
        cc_owner,
        cc_date,
        note
    from
        income
    where
        ( nvl(amount, 0) <> 0
          or nvl(amount_add, 0) <> 0
          or nvl(er_fee_amount, 0) <> 0
          or nvl(ee_fee_amount, 0) <> 0 );

