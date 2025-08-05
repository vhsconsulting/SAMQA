-- liquibase formatted sql
-- changeset SAMQA:1754374157637 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_errors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_errors.sql:null:bf4d06f76fe0b60133b386840b22282b795c8eae:create

create table samqa.eob_errors (
    err_id        number,
    label         varchar2(100 byte),
    message       varchar2(3200 byte),
    creation_date date
);

