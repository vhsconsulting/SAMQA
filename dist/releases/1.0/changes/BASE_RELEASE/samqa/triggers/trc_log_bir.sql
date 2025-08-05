-- liquibase formatted sql
-- changeset SAMQA:1754374166126 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\trc_log_bir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/trc_log_bir.sql:null:4dcac0f1eefa70881101020a4a10b48c7c7e5a06:create

create or replace editionable trigger samqa.trc_log_bir before
    insert on samqa.trc_log
    for each row
begin
    select
        trc_seq.nextval
    into :new.event_id
    from
        dual;

end;
/

alter trigger samqa.trc_log_bir enable;

