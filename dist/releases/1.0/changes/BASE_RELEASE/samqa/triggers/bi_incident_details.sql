-- liquibase formatted sql
-- changeset SAMQA:1754374164929 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\bi_incident_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/bi_incident_details.sql:null:3c8df728928d1d003495a5d89e16441c733f316c:create

create or replace editionable trigger samqa.bi_incident_details before
    insert on samqa.incident_details
    for each row
begin
    if :new.incident_id is null then
        select
            incident_details_seq.nextval
        into :new.incident_id
        from
            sys.dual;

    end if;
end;
/

alter trigger samqa.bi_incident_details enable;

