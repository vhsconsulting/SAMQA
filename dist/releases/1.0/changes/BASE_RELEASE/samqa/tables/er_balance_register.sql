-- liquibase formatted sql
-- changeset SAMQA:1754374157789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\er_balance_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/er_balance_register.sql:null:ed4845fafa8a917c0935a63e8710605c11c6ef6c:create

create table samqa.er_balance_register (
    register_id      number not null enable,
    entrp_id         number,
    transaction_date date,
    reason_code      varchar2(500 byte),
    note             varchar2(3200 byte),
    amount           number,
    reason_mode      varchar2(10 byte),
    entity_id        number,
    entity_type      varchar2(255 byte),
    plan_type        varchar2(30 byte),
    creation_date    date default sysdate,
    last_update_date date default sysdate
);

alter table samqa.er_balance_register
    add constraint er_balance_register_pk primary key ( register_id )
        using index enable;

