-- liquibase formatted sql
-- changeset SAMQA:1754374162177 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\person_audit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/person_audit.sql:null:e8fa6327e4fb03f24bf36e366701188bc8c938e8:create

create table samqa.person_audit (
    pers_id      number(9, 0) not null enable,
    old_ssn      varchar2(20 byte),
    new_ssn      varchar2(20 byte),
    changed_user number,
    changed_date date,
    sl_no        number
);

