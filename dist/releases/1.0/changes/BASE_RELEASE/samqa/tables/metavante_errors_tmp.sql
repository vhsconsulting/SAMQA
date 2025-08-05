-- liquibase formatted sql
-- changeset SAMQA:1754374160704 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_errors_tmp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_errors_tmp.sql:null:510c82b3ab4e380f05ac72f3f3c7238999360bb0:create

create table samqa.metavante_errors_tmp (
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

