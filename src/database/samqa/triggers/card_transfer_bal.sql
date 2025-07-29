create or replace editionable trigger samqa.card_transfer_bal after
    insert or update or delete on samqa.card_transfer
    for each row
declare
    ac_v number;
begin
/* Mark account changed, for calc balance
  08.01.2006 mal  creation
 */
    if inserting then
        select
            acc_id
        into ac_v
        from
            card_debit_acc
        where
            card_id = :new.card_id;

        insert into balance_register (
            register_id,
            acc_id,
            fee_date,
            reason_code,
            note,
            amount,
            reason_mode,
            change_id
        ) values ( balance_register_seq.nextval,
                   ac_v,
                   :new.transfer_date,
                   21,
                   'Card Transfer',
                   - nvl(:new.transfer_amount,
                         0),
                   'C',
                   :new.transfer_id );

    elsif updating then
        select
            acc_id
        into ac_v
        from
            card_debit_acc
        where
            card_id = :new.card_id;

        update balance_register
        set
            amount = - nvl(:new.transfer_amount,
                           0),
            reason_code = 21
        where
                change_id = :new.transfer_id
            and acc_id = ac_v;

    elsif deleting then
        delete from balance_register
        where
            change_id = :old.transfer_id;

    end if;
end card_transfer_bal;
/

alter trigger samqa.card_transfer_bal enable;


-- sqlcl_snapshot {"hash":"1d676fd0f60958a7b77b8c69fab4a4091d90a931","type":"TRIGGER","name":"CARD_TRANSFER_BAL","schemaName":"SAMQA","sxml":""}