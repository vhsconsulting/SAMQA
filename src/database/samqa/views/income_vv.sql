create or replace force editionable view samqa.income_vv (
    change_num,
    acc_id,
    fee_date,
    fee_code,
    amount,
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
        fee_code,
        amount,
        contributor,
        pay_code,
        cc_number,
        cc_code,
        cc_owner,
        cc_date,
        note
    from
        income_v;


-- sqlcl_snapshot {"hash":"0f01da895f3b24162a1a570d9bd85c757d09d91b","type":"VIEW","name":"INCOME_VV","schemaName":"SAMQA","sxml":""}