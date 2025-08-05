-- liquibase formatted sql
-- changeset SAMQA:1754374164363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\website_logs_temp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/website_logs_temp.sql:null:8ae7713b3a4762451bf3989bf77ff597fe4ba34f:create

create table samqa.website_logs_temp (
    log_id        number,
    component     varchar2(3200 byte),
    message       varchar2(3200 byte),
    creation_date date
);

