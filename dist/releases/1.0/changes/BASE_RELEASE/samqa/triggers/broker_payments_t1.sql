-- liquibase formatted sql
-- changeset SAMQA:1754374164976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\broker_payments_t1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/broker_payments_t1.sql:null:d998b250e2710be23632903a14f3ce238cc5955c:create

create or replace editionable trigger samqa.broker_payments_t1 before
    insert or update on samqa.broker_payments
    for each row
begin
    if inserting then
        :new.creation_date := sysdate;
        :new.created_by := get_user_id(v('APP_USER'));
    end if;

    if updating then
        :new.last_update_date := sysdate;
        :new.last_updated_by := get_user_id(v('APP_USER'));
    end if;

end;
/

alter trigger samqa.broker_payments_t1 enable;

