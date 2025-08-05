-- liquibase formatted sql
-- changeset SAMQA:1754374165740 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\insert_person_af.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/insert_person_af.sql:null:3021362f1a745120622f8220a1b2d250636327d7:create

create or replace editionable trigger samqa.insert_person_af after
    insert on samqa.person
    for each row
declare
    v_update_id    number;
    v_acc_num      varchar2(30);
    v_account_type varchar2(30) := null;
    v_acc_id       number;
begin
        --
        -- get the Account Number from ACCOUNT
        --
    begin
        select
            acc_num,
            account_type
        into
            v_acc_num,
            v_account_type
        from
            account
        where
            account.pers_id = :new.pers_id;

    exception
        when no_data_found then
            null;
    end;

    if v_acc_num is null then
        begin
            select
                acc_num,
                account_type,
                acc_id
            into
                v_acc_num,
                v_account_type,
                v_acc_id
            from
                account
            where
                account.pers_id = :new.pers_main;

        exception
            when no_data_found then
                null;
        end;

    end if;

    if
        v_acc_num is not null
        and v_account_type in ( 'HRA', 'FSA' )
    then

           -- get the next update id
        insert into metavante_outbound (
            request_id,
            action,
            pers_id,
            acc_id,
            acc_num,
            bps_acc_num,
            processed_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                eb_update_seq.nextval,
                'DEPENDANT_INSERT',
                :new.pers_id,
                v_acc_id,
                v_acc_num,
                null,
                'N',
                sysdate,
                get_user_id(v('APP_USER')),
                sysdate,
                get_user_id(v('APP_USER'))
            from
                dual;

    end if;

end;
/

alter trigger samqa.insert_person_af enable;

