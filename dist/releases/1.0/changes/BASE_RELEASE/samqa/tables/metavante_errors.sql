-- liquibase formatted sql
-- changeset SAMQA:1754374160701 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_errors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_errors.sql:null:94d47601c1d0adbf685e5e7fa0f559ecf9ef3048:create

create table samqa.metavante_errors (
    error_id               number,
    record_id              varchar2(30 byte),
    employer_id            varchar2(30 byte),
    employee_id            varchar2(30 byte),
    action_code            varchar2(255 byte),
    detail_response_code   varchar2(3200 byte),
    record_tracking_number varchar2(30 byte),
    creation_date          date,
    last_update_date       date,
    dependant_id           number,
    file_name              varchar2(100 byte)
);

