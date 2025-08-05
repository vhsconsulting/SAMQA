create or replace editionable trigger samqa.employer_payments_af after
    insert or update or delete on samqa.employer_payments
    for each row
declare
    l_posted_balance     number := 0;
    l_old_posted_balance number := 0;
    l_remaining_balance  number := 0;
    l_reason_mode        varchar2(1);
    l_account_type       varchar2(30);
    l_fee_code           number;
    l_reg_id             number;
    l_exists_flag        varchar2(1) := 'N';
    l_deposit_exist      varchar2(1) := 'N';
begin
    if :new.transaction_source in ( 'CLAIM_PAYMENT', 'PENDING_ACH', 'PENDING_CHECK' ) then -- dont insert into balance register for annual election

        if inserting then
            insert into er_balance_register (
                register_id,
                entrp_id,
                transaction_date,
                reason_code,
                note,
                amount,
                reason_mode,
                entity_id,
                entity_type,
                plan_type
            ) values ( er_bal_register_seq.nextval,
                       :new.entrp_id,
                       :new.check_date,
                       :new.reason_code,
                       :new.note,
                       nvl(:new.check_amount,
                           0),
                       'P',
                       :new.employer_payment_id,
                       'EMPLOYER_PAYMENTS',
                       :new.plan_type );

        elsif updating then
            update er_balance_register
            set
                amount = nvl(:new.check_amount,
                             0),
                reason_code = :new.reason_code,
                reason_mode = 'I',
                note = :new.note,
                transaction_date = :new.check_date,
                plan_type = :new.plan_type
            where
                    entity_id = :new.employer_payment_id
                and entity_type = 'EMPLOYER_PAYMENTS'
                and entrp_id = :new.entrp_id;

        end if;
    end if;

    if
        deleting
        and :old.transaction_source in ( 'CLAIM_PAYMENT', 'PENDING_ACH', 'PENDING_CHECK' )
    then
        delete from er_balance_register
        where
                entity_id = :new.employer_payment_id
            and entity_type = 'EMPLOYER_PAYMENTS'
            and entrp_id = :new.entrp_id;

        insert into employer_payment_del (
            employer_payment_id,
            entrp_id,
            check_amount,
            check_number,
            check_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            reason_code,
            transaction_date,
            plan_type,
            transaction_source,
            plan_start_date,
            plan_end_date
        ) values ( :old.employer_payment_id,
                   :old.entrp_id,
                   nvl(:old.check_amount,
                       0),
                   :old.check_number,
                   :old.check_date,
                   sysdate,
                   0,
                   sysdate,
                   0,
                   pc_lookups.get_reason_name(:old.reason_code),
                   :old.reason_code,
                   :old.transaction_date,
                   :old.plan_type,
                   :old.transaction_source,
                   :old.plan_start_date,
                   :old.plan_end_date );

    end if;

end;
/

alter trigger samqa.employer_payments_af enable;


-- sqlcl_snapshot {"hash":"f8d36433db3f5bd62ce15d2f4e47ecad29579e11","type":"TRIGGER","name":"EMPLOYER_PAYMENTS_AF","schemaName":"SAMQA","sxml":""}