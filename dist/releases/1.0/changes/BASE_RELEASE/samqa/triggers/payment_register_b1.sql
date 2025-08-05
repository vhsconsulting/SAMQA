-- liquibase formatted sql
-- changeset SAMQA:1754374166055 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\payment_register_b1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/payment_register_b1.sql:null:baa406b8605291826f2587d423b6210cefaff74f:create

create or replace editionable trigger samqa.payment_register_b1 before
    insert or update on samqa.payment_register
    for each row
begin
    if inserting then
        :new.created_by := get_user_id(v('APP_USER'));
        :new.creation_date := sysdate;
    end if;

    if updating then
        :new.last_updated_by := get_user_id(v('APP_USER'));
        :new.last_update_date := sysdate;
    end if;

end;
/

alter trigger samqa.payment_register_b1 enable;

