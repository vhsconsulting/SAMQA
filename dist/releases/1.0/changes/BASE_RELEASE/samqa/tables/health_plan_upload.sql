-- liquibase formatted sql
-- changeset SAMQA:1754374159264 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\health_plan_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/health_plan_upload.sql:null:83da3cf84187425e096b9f68196ff300d34a8d92:create

create table samqa.health_plan_upload (
    health_plan_id   number,
    first_name       varchar2(100 byte),
    last_name        varchar2(100 byte),
    ssn              varchar2(20 byte),
    acc_num          varchar2(20 byte),
    acc_id           number,
    carrier          varchar2(255 byte),
    effective_date   varchar2(100 byte),
    deductible       number,
    plan_type        varchar2(100 byte),
    account_type     varchar2(100 byte),
    processed_status varchar2(1 byte) default 'N',
    error_message    varchar2(1000 byte),
    batch_number     number,
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number
);

alter table samqa.health_plan_upload add primary key ( health_plan_id )
    using index enable;

