-- liquibase formatted sql
-- changeset SAMQA:1754374169659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\card_transfer_acc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/card_transfer_acc.sql:null:e3005cab6e88960613f714953fffb1ceafb7434d:create

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

