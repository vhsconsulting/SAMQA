-- liquibase formatted sql
-- changeset SAMQA:1754374165367 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\enterprise_af.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/enterprise_af.sql:null:6c716551330217ad44e0a9ca3eb3e0136e6d0a99:create

create or replace editionable trigger samqa.enterprise_af after
    insert or update on samqa.enterprise
    for each row
begin
    if :old.note <> :new.note then
        pc_utility.insert_notes(:new.entrp_id,
                                'ENTERPRISE',
                                :new.note,
                                get_user_id(v('APP_USER')),
                                sysdate,
                                null,
                                null,
                                :old.entrp_id);

    end if;
end;
/

alter trigger samqa.enterprise_af enable;

