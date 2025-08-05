create or replace force editionable view samqa.acc_op (
    change_num,
    acc_id,
    fee_date,
    amount,
    fee_code,
    cc_number,
    note,
    reason_name,
    cur_bal,
    tbl
) as
    (
        select
            i.change_num,
            i.acc_id,
            i.fee_date,
            i.amount + nvl(i.amount_add, 0),
            i.fee_code,
            i.cc_number,
            i.note,
            f.fee_name,
            i.cur_bal,
            'I'
        from
            income    i,
            fee_names f
        where
            i.fee_code = f.fee_code (+)
        union all
        select
            p.change_num,
            p.acc_id,
            p.pay_date,
            - p.amount         amount,
            p.reason_code,
            to_char(p.pay_num) as pn,
            trim(c.prov_name
                 || ' '
                 || c.note
                 || ' '
                 || p.note),
            r.reason_name,
            p.cur_bal,
            'P'
        from
            payment    p,
            claimn     c,
            pay_reason r
        where
                p.claimn_id = c.claim_id (+)
            and p.reason_code = r.reason_code
        union all
        select
            transfer_id,
            acc_id,
            transfer_date,
            - transfer_amount transfer_amount,
            21,
            to_char(card_id),
            note,
            'CARD_TRANSFER',
            cur_bal,
            'T'
        from
            card_transfer_acc
    );


-- sqlcl_snapshot {"hash":"017f16ae2359a681fe6aefe1cac6683eac70a932","type":"VIEW","name":"ACC_OP","schemaName":"SAMQA","sxml":""}