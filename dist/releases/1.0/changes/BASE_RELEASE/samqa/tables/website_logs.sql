-- liquibase formatted sql
-- changeset SAMQA:1754374164353 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\website_logs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/website_logs.sql:null:40eee1670b7548c24a1046dd44dfd84709a24416:create

create table samqa.website_logs (
    log_id        number,
    component     varchar2(3200 byte),
    message       varchar2(4000 byte),
    creation_date date
);

