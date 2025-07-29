create or replace force editionable view samqa.card_transfer_acc (
    acc_id,
    pers_id,
    transfer_id,
    card_id,
    transfer_date,
    transfer_amount,
    note,
    cur_bal
) as
    (
        select
            a.acc_id,
            a.pers_id,
            t.transfer_id,
            t.card_id,
            t.transfer_date,
            t.transfer_amount,
            t.note,
            t.cur_bal
        from
            card_transfer  t,
            card_debit_acc a
        where
            t.card_id = a.card_id
    );


-- sqlcl_snapshot {"hash":"e3005cab6e88960613f714953fffb1ceafb7434d","type":"VIEW","name":"CARD_TRANSFER_ACC","schemaName":"SAMQA","sxml":""}