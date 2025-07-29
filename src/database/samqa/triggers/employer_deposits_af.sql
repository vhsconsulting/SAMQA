create or replace editionable trigger samqa.employer_deposits_af after
    insert or update or delete on samqa.employer_deposits
    for each row
declare
    l_account_type varchar2(30);
begin
    if inserting
    or updating then
        update deposit_register
        set
            posted_flag = decode(:new.posted_balance,
                                 :new.check_amount,
                                 'Y',
                                 'N'),
            reconciled_flag = decode(:new.remaining_balance,
                                     0,
                                     'N',
                                     'Y'),
            last_updated_by = get_user_id(v('APP_USER')),
            last_update_date = sysdate
        where
                entrp_id = :new.entrp_id
            and list_bill = :new.list_bill;
   
    /*** Deposit Register already has values ***/
        if sql%rowcount = 0 then
            insert into deposit_register (
                deposit_register_id,
                first_name,
                acc_num,
                check_number,
                check_amount,
                trans_date,
                status,
                posted_flag,
                reconciled_flag,
                entrp_id,
                acc_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                list_bill,
                orig_sys_ref
            )
                select
                    deposit_register_seq.nextval,
                    c.name,
                    b.acc_num,
                    :new.check_number,
                    :new.check_amount,
                    to_char(:new.check_date,
                            'MM/DD/YYYY'),
                    'EXISTING',
                    decode(:new.posted_balance,
                           0,
                           'N',
                           'Y'),
                    decode(:new.remaining_balance,
                           0,
                           'N',
                           'Y'),
                    c.entrp_id,
                    b.acc_id,
                    sysdate,
                    get_user_id(v('APP_USER')),
                    sysdate,
                    get_user_id(v('APP_USER')),
                    :new.list_bill,
                    :new.employer_deposit_id
                from
                    enterprise c,
                    account    b
                where
                        c.entrp_id = :new.entrp_id
                    and c.entrp_id = b.entrp_id
                    and not exists (
                        select
                            *
                        from
                            deposit_register
                        where
                                deposit_register.orig_sys_ref = :new.employer_deposit_id
                            and deposit_register.acc_id = b.acc_id
                    );

        end if;

    end if;

    if inserting
    or updating then
        for x in (
            select
                account_type
            from
                account
            where
                entrp_id = :new.entrp_id
        ) loop
            l_account_type := x.account_type;
        end loop;

    else
        for x in (
            select
                account_type
            from
                account
            where
                entrp_id = :old.entrp_id
        ) loop
            l_account_type := x.account_type;
        end loop;
    end if;

    if
        nvl(:new.reason_code,
            -1) not in ( 5, 11, 12, 15, 8,
                         17, 18, 40 )
        and l_account_type in ( 'HRA', 'FSA' )
    then -- dont insert into balance register for annual election

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
                       'I',
                       :new.employer_deposit_id,
                       'EMPLOYER_DEPOSITS',
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
                    entity_id = :new.employer_deposit_id
                and entity_type = 'EMPLOYER_DEPOSITS'
                and entrp_id = :new.entrp_id;

        elsif deleting then
            delete from er_balance_register
            where
                    entity_id = :new.employer_deposit_id
                and entity_type = 'EMPLOYER_DEPOSITS'
                and entrp_id = :new.entrp_id;

        end if;
    end if;

end;
/

alter trigger samqa.employer_deposits_af enable;


-- sqlcl_snapshot {"hash":"4f04b6a3aaa71a09491c819b12fb2d69854f6957","type":"TRIGGER","name":"EMPLOYER_DEPOSITS_AF","schemaName":"SAMQA","sxml":""}