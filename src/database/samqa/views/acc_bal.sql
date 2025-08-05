create or replace force editionable view samqa.acc_bal (
    change_num,
    acc_id,
    op_date,
    amount,
    op_code,
    cnum,
    note,
    cur_bal,
    tbl
) as
    (
        select
            change_num,
            acc_id,
            fee_date,
            amount + nvl(amount_add, 0),
            fee_code,
            cc_number,
            note,
            cur_bal,
            'I'
        from
            income
        union all
        select
            change_num,
            acc_id,
            pay_date,
            - amount,
            reason_code,
            to_char(pay_num),
            note,
            cur_bal,
            'P'
        from
            payment
    );


-- sqlcl_snapshot {"hash":"61529ad21c13a90d006803054d4f103374c055b5","type":"VIEW","name":"ACC_BAL","schemaName":"SAMQA","sxml":""}