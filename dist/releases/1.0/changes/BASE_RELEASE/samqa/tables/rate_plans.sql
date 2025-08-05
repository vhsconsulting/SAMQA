-- liquibase formatted sql
-- changeset SAMQA:1754374162508 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\rate_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/rate_plans.sql:null:8a2b06b3933e1c5ec630fb2607a1df1597f12ff6:create

create table samqa.rate_plans (
    rate_plan_id         number not null enable,
    rate_plan_name       varchar2(255 byte),
    entity_type          varchar2(30 byte),
    entity_id            number,
    status               varchar2(30 byte) default 'A',
    note                 varchar2(3200 byte),
    effective_date       date default sysdate,
    effective_end_date   date,
    creation_date        date default sysdate,
    created_by           number,
    last_update_date     date default sysdate,
    last_updated_by      number,
    rate_plan_type       varchar2(30 byte),
    sales_team_member_id number,
    division_invoicing   varchar2(1 byte) default 'N',
    account_type         varchar2(30 byte),
    division_code        varchar2(100 byte)
);

alter table samqa.rate_plans add primary key ( rate_plan_id )
    using index enable;

