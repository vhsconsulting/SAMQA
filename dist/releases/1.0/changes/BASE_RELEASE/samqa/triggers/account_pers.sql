-- liquibase formatted sql
-- changeset SAMQA:1754374164450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\account_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/account_pers.sql:null:ed69d126d7786037ec0b9c5966a8c6a8f2148c1c:create

create or replace editionable trigger samqa.account_pers after
    insert or update or delete on samqa.account
    for each row
    when ( new.pers_id is not null
           or old.pers_id is not null )
declare
    pers_v              account.pers_id%type;
    anum_v              account.acc_num%type;
    v_debit_card_status varchar2(30);
    v_update_id         number;
begin
/*
 Copy account number from ACCOUNT to PERSON
  03.07.2006 mal  Created
*/
    if inserting
    or updating then
        pers_v := :new.pers_id;
        anum_v := :new.acc_num;
    elsif deleting then
        pers_v := :old.pers_id;
        anum_v := null;
        if :old.pers_id is not null then
            pc_utility.insert_notes(:old.pers_id,
                                    'PERSON',
                                    'Account has been deleted',
                                    get_user_id(v('APP_USER')),
                                    sysdate,
                                    :old.pers_id,
                                    :old.acc_id,
                                    null);
        else
            pc_utility.insert_notes(:old.entrp_id,
                                    'ENTERPRISE',
                                    'Account has been deleted',
                                    get_user_id(v('APP_USER')),
                                    sysdate,
                                    null,
                                    :old.acc_id,
                                    :old.entrp_id);
        end if;

    end if;

    update person
    set
        acc_numc = reverse(anum_v)
    where
        pers_id = pers_v;

    if :old.acc_num <> :new.acc_num then
        begin
            select
                status
            into v_debit_card_status
            from
                card_debit
            where
                card_id = :new.pers_id;

        exception
            when no_data_found then
                v_debit_card_status := null;
        end;

    --
    -- only record change for debit cards if status is not null
    -- 1) debit card record not found, or
    -- 2) debit card is closed
    --
        if v_debit_card_status is not null
           or v_debit_card_status <> 3 then
            pc_utility.insert_notes(:new.acc_id,
                                    'ACCOUNT',
                                    'Account Number Changed',
                                    get_user_id(v('APP_USER')),
                                    sysdate,
                                    :new.pers_id,
                                    :new.acc_id,
                                    :new.entrp_id);

    --
    -- get the next update id
    --
            select
                eb_update_seq.nextval
            into v_update_id
            from
                dual;

    --
    -- insert the row as unprocessed
    --
            insert into debit_card_updates (
                update_id,
                pers_id,
                acc_num,
                old_acc_num,
                acc_num_changed,
                acc_num_processed,
                demo_changed,
                demo_processed
            ) values ( v_update_id,
                       :new.pers_id,
                       :new.acc_num,
                       :old.acc_num,
                       'Y',
                       'N',
                       'N',
                       'N' );

        end if;

    end if;

exception -- no need ???
    when others then
        raise_application_error(-20001, 'TRIGGER ACCOUNT_PERS ' || sqlerrm);
end account_pers;
/

alter trigger samqa.account_pers enable;

