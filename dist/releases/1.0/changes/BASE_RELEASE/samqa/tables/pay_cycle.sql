-- liquibase formatted sql
-- changeset SAMQA:1754374161836 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\pay_cycle.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/pay_cycle.sql:null:1c14f495a8d9c8282420fabab11df3401e35dbc8:create

create table samqa.pay_cycle (
    pay_cycle_id     number not null enable,
    name             varchar2(100 byte),
    entrp_id         number,
    start_date       date,
    end_date         date,
    frequency        varchar2(100 byte),
    created_by       number,
    creation_date    date default sysdate,
    last_updated_by  number,
    last_update_date date default sysdate,
    plan_type        varchar2(100 byte),
    ben_plan_id      number,
    no_of_periods    number
);

alter table samqa.pay_cycle add primary key ( pay_cycle_id )
    using index enable;

