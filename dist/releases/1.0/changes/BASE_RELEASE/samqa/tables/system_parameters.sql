-- liquibase formatted sql
-- changeset SAMQA:1754374163589 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\system_parameters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/system_parameters.sql:null:ad18234d2eb0fe5d2b49cc29e432a8da3038206b:create

create table samqa.system_parameters (
    param_id          number,
    param_description varchar2(300 byte),
    param_code        varchar2(30 byte),
    param_value       varchar2(60 byte),
    effective_date    date,
    creation_date     date,
    account_type      varchar2(30 byte) default 'HSA',
    plan_type         varchar2(30 byte)
);

