-- liquibase formatted sql
-- changeset SAMQA:1754374167811 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\activity_stmt_income_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/activity_stmt_income_v.sql:null:b1b849e96aee969b02bd5dbd1584e7054d7f6932:create

create or replace force editionable view samqa.activity_stmt_income_v (
    ee_amount,
    er_amount,
    interest,
    acc_id,
    fee_code,
    fee_date
) as
    select
        nvl(amount_add, 0) + nvl(ee_fee_amount, 0)     ee_amount,
        decode(fee_code,
               8,
               0,
               nvl(amount, 0)) + nvl(er_fee_amount, 0) er_amount,
        decode(fee_code,
               8,
               nvl(amount, 0),
               0)                                      interest,
        b.acc_id,
        decode(fee_code, 8, 8, null)                   fee_code,
        trunc(fee_date)                                fee_date
    from
        income  a,
        account b
    where
        a.acc_id = b.acc_id;

