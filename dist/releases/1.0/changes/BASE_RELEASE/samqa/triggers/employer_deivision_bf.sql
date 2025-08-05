-- liquibase formatted sql
-- changeset SAMQA:1754374165203 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\employer_deivision_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/employer_deivision_bf.sql:null:34bf500a783d77078b28fd94dfa6979fb94da842:create

create or replace editionable trigger samqa.employer_deivision_bf before
    insert or update on samqa.employer_divisions
    for each row
begin
    :new.division_code := upper(:new.division_code);
end;
/

alter trigger samqa.employer_deivision_bf enable;

