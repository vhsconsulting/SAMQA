create or replace editionable trigger samqa.ach_transfer_bal after
    insert or update or delete on samqa.ach_transfer
    for each row
declare
    l_reason_mode    varchar2(30);
    l_fee_bucket_bal number;
begin
    if inserting then
        if
            :new.transaction_type = 'D'
            and :new.status in ( 1, 2 )
        then
            insert into balance_register (
                register_id,
                acc_id,
                fee_date,
                reason_code,
                note,
                amount,
                reason_mode,
                change_id,
                plan_type
            ) values ( balance_register_seq.nextval,
                       :new.acc_id,
                       :new.transaction_date,
                       111,
                       'Pending Subscriber Disbursement',
                       - :new.total_amount,
                       'EP',
                       :new.acc_id
                       || :new.transaction_id,
                       :new.plan_type );

        end if;

    elsif updating then
        if :new.status = 9 then
            delete from balance_register
            where
                    change_id = :new.acc_id
                                || :new.transaction_id
                and acc_id = :new.acc_id;

        else
            update balance_register
            set
                amount = - :new.amount,
                note = 'Pending Subscriber Disbursement'
            where
                    change_id = :new.acc_id
                                || :new.transaction_id
                and acc_id = :new.acc_id;

        end if;
    elsif deleting then
        delete from balance_register
        where
                change_id = :old.acc_id
                            || :old.transaction_id
            and acc_id = :old.acc_id;

    end if;
end ach_transfer_bal;
/

alter trigger samqa.ach_transfer_bal enable;


-- sqlcl_snapshot {"hash":"c29dcc20e89ca17b6346cbe7cfd90c8ba1c83a9e","type":"TRIGGER","name":"ACH_TRANSFER_BAL","schemaName":"SAMQA","sxml":""}