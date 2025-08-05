-- liquibase formatted sql
-- changeset SAMQA:1754374165776 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\insure_af.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/insure_af.sql:null:ee05460690f34a86f5f4f9adf227727ee1d4c6f7:create

create or replace editionable trigger samqa.insure_af after
    update or delete on samqa.insure
    for each row
begin
    if :old.insur_id <> :new.insur_id
    or :old.carrier_supported <> :new.carrier_supported
    or :old.carrier_user_name <> :new.carrier_user_name
    or :old.carrier_password <> :new.carrier_password
    or :old.allow_eob <> :new.allow_eob
    or :old.plan_type <> :new.plan_type
    or :old.allow_eob <> :new.allow_eob
    or :old.revoked_date <> :new.revoked_date then
        insert into insure_history (
            pers_id,
            insur_id,
            policy_num,
            start_date,
            end_date,
            group_no,
            deductible,
            op_max,
            note,
            plan_type,
            eob_connection_status,
            allow_eob,
            carrier_supported,
            carrier_user_name,
            carrier_password,
            revoked_date,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by
        ) values ( :old.pers_id,
                   :old.insur_id,
                   :old.policy_num,
                   :old.start_date,
                   :old.end_date,
                   :old.group_no,
                   :old.deductible,
                   :old.op_max,
                   :old.note,
                   :old.plan_type,
                   :old.eob_connection_status,
                   :old.allow_eob,
                   :old.carrier_supported,
                   :old.carrier_user_name,
                   :old.carrier_password,
                   :old.revoked_date,
                   sysdate,
                   :old.last_updated_by,
                   sysdate,
                   :old.created_by );

    end if;
end;
/

alter trigger samqa.insure_af enable;

