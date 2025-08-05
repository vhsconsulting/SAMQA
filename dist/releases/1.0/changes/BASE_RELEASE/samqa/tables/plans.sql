-- liquibase formatted sql
-- changeset SAMQA:1754374162402 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/plans.sql:null:bd0f0e42b80e4b3e1fdd249e8c1f89128c0ec367:create

create table samqa.plans (
    plan_code           number(3, 0) not null enable,
    plan_name           varchar2(100 byte) not null enable,
    plan_sign           varchar2(3 byte),
    note                varchar2(4000 byte),
    entrp_id            number,
    account_type        varchar2(10 byte) default 'HSA',
    status              varchar2(1 byte) default 'A',
    plan_suffix         varchar2(30 byte),
    custom_plan         varchar2(1 byte) default 'N',
    show_online_flag    varchar2(2 byte),
    annual_flag         varchar2(1 byte) default 'N',
    minimum_bal         number default 20,
    create_card_on_pend varchar2(1 byte) default 'N'
);

create unique index samqa.plans_pk on
    samqa.plans (
        plan_code
    );

alter table samqa.plans
    add constraint plans_pk
        primary key ( plan_code )
            using index samqa.plans_pk enable;

