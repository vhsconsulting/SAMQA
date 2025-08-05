-- liquibase formatted sql
-- changeset SAMQA:1754374159246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\health_plan_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/health_plan_external.sql:null:f5c8183de6457be494518d20ae5a02d10de37d9d:create

create table samqa.health_plan_external (
    first_name     varchar2(100 byte),
    last_name      varchar2(100 byte),
    ssn            varchar2(20 byte),
    acc_num        varchar2(20 byte),
    carrier        varchar2(100 byte),
    effective_date varchar2(100 byte),
    deductible     number,
    plan_type      varchar2(100 byte),
    account_type   varchar2(6 byte)
);

