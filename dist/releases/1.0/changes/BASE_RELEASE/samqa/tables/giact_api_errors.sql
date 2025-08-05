-- liquibase formatted sql
-- changeset SAMQA:1754374158943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\giact_api_errors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/giact_api_errors.sql:null:5388e128013e8729bf99549447e06736c71900f9:create

create table samqa.giact_api_errors (
    batch_number    number,
    error_code      varchar2(100 byte),
    error_message   varchar2(2000 byte),
    error_backtrace varchar2(2000 byte),
    error_timestamp varchar2(100 byte),
    request_data    clob,
    entity_id       number
);

