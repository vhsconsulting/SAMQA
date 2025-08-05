create or replace editionable trigger samqa.bank_accounts_bf before
    insert or update on samqa.bank_accounts
    for each row
declare
    l_user_name varchar2(250);
begin
    if :new.bank_acct_type = 'C' then
        :new.bank_acct_code := 'D'; -- changing on 09/18/2018 as per shavee request
    end if;

    if :new.bank_acct_type = 'S' then
        :new.bank_acct_code := 'S'; -- changing on 09/18/2018 as per shavee request
    end if;

  -- Added by Jaggi 11078
    if inserting then
        if :new.authorized_by is null then
            if get_user_id(v('APP_USER')) is not null then
                l_user_name := get_user_name(get_user_id(v('APP_USER')));
            else
                l_user_name := pc_users.get_user_name(:new.created_by);
            end if;

            :new.authorized_by := l_user_name;
        end if;
    end if;

 -- Below Code added by Swamy for Ticket#6794(ACN Migration)
 -- New bank Details for HSA should be Migrated to ACN, if Subscribe_to_acn flay is 'Y'
    if
        inserting
        and nvl(:new.entity_type,
                'ACCOUNT') = 'ACCOUNT'
    then
        for i in (
            select
                a.entrp_id
            from
                account            a,
                account_preference p
            where
                    a.acc_id = :new.entity_id
                and a.entrp_id is not null
                and a.acc_id = p.acc_id
                and nvl(p.subscribe_to_acn, 'N') = 'Y'
        ) loop
            pc_acn_migration.insert_acn_employer_migration(
                p_acc_id      => :new.entity_id,
                p_entrp_id    => i.entrp_id,
                p_action_type => 'U'
            );
        end loop;
    end if;

end;
/

alter trigger samqa.bank_accounts_bf enable;


-- sqlcl_snapshot {"hash":"a1644d5d5b5f04895940b0434568ede84bcbe088","type":"TRIGGER","name":"BANK_ACCOUNTS_BF","schemaName":"SAMQA","sxml":""}