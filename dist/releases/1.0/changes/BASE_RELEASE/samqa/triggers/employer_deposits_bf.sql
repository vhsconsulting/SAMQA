-- liquibase formatted sql
-- changeset SAMQA:1754374165299 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\employer_deposits_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/employer_deposits_bf.sql:null:d3ecabff184cb69513d0e81ef3f0e6ad79d3c8b1:create

create or replace editionable trigger samqa.employer_deposits_bf before
    insert or update on samqa.employer_deposits
    for each row
begin
    if inserting then
        :new.creation_date := sysdate;
        :new.created_by := get_user_id(v('APP_USER'));
    end if;

    :new.last_update_date := sysdate;
    :new.last_updated_by := get_user_id(v('APP_USER'));
end;
/

alter trigger samqa.employer_deposits_bf enable;

