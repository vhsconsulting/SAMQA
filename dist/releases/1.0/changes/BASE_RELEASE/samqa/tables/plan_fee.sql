-- liquibase formatted sql
-- changeset SAMQA:1754374162329 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\plan_fee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/plan_fee.sql:null:6ef790dbf30b7d806e1ad96e4c63f9c1c63152f0:create

create table samqa.plan_fee (
    plan_code        number(3, 0) not null enable,
    fee_code         number(3, 0) not null enable,
    fee_name         varchar2(100 byte),
    fee_amount       number(15, 2),
    note             varchar2(4000 byte),
    dependant_cost   number,
    plan_type        varchar2(30 byte),
    status           varchar2(1 byte),
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number
);

create unique index samqa.plans_fee_pk on
    samqa.plan_fee (
        plan_code,
        fee_code
    );

alter table samqa.plan_fee
    add constraint plans_fee_pk
        primary key ( plan_code,
                      fee_code )
            using index samqa.plans_fee_pk enable;

