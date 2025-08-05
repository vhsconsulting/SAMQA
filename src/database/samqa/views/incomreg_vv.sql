create or replace force editionable view samqa.incomreg_vv (
    change_num,
    pers_id,
    account,
    fee_date,
    amount,
    fee_amount,
    type_of_deposit,
    note,
    cc_number,
    account_type,
    plan_name
) as
    select
        ine.change_num change_num,
        acc.pers_id    pers_id,
        acc.acc_num    account,
        ine.fee_date   fee_date,
        ine.amount     amount,
        ine.fee_amount fee_amount,
        pte.pay_name   type_of_deposit,
        ine.note       note,
        ine.cc_number  cc_number,
        acc.account_type,
        p.plan_name
    from
        account  acc,
        pay_type pte,
        income_v ine,
        plans    p
    where
            ine.acc_id = acc.acc_id
        and ine.pay_code = pte.pay_code
        and acc.plan_code = p.plan_code;


-- sqlcl_snapshot {"hash":"25078bd44707312f8a9c182f7072a03cdd6fbe9f","type":"VIEW","name":"INCOMREG_VV","schemaName":"SAMQA","sxml":""}