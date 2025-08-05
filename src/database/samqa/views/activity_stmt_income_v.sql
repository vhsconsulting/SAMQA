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


-- sqlcl_snapshot {"hash":"b1b849e96aee969b02bd5dbd1584e7054d7f6932","type":"VIEW","name":"ACTIVITY_STMT_INCOME_V","schemaName":"SAMQA","sxml":""}