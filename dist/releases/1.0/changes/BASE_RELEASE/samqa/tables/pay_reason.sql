-- liquibase formatted sql
-- changeset SAMQA:1754374161901 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\pay_reason.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/pay_reason.sql:null:7e091b7101d304f7a2e4fe60ca2ea06da3ed08b0:create

create table samqa.pay_reason (
    reason_code      number(3, 0) not null enable,
    reason_name      varchar2(100 byte) not null enable,
    show_lov         varchar2(1 byte),
    reason_type      varchar2(30 byte),
    plan_type        varchar2(30 byte),
    status           varchar2(1 byte),
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number,
    reason_mapping   number,
    product_type     varchar2(30 byte),
    gp_item_number   varchar2(255 byte)
);

create unique index samqa.pay_reason_pk on
    samqa.pay_reason (
        reason_code
    );

alter table samqa.pay_reason
    add constraint pay_reason_pk
        primary key ( reason_code )
            using index samqa.pay_reason_pk enable;

