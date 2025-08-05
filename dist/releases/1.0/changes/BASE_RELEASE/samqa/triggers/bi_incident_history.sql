-- liquibase formatted sql
-- changeset SAMQA:1754374164944 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\bi_incident_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/bi_incident_history.sql:null:fec9b7f4421365e58e4484237e68ecdc5436d6dc:create

create or replace editionable trigger samqa.bi_incident_history before
    insert on samqa.incident_history
    for each row
begin
    if :new.history_id is null then
        select
            incident_history_seq.nextval
        into :new.history_id
        from
            sys.dual;

    end if;
end;
/

alter trigger samqa.bi_incident_history enable;

