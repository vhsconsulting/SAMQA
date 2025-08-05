-- liquibase formatted sql
-- changeset SAMQA:1754374152982 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\checkbook_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/checkbook_gp.sql:null:64f8a7e8338396ece8a8651a85cb6b7ff58ac339:create

create table samqa.checkbook_gp (
    checkbook_id     number,
    checkbook_code   varchar2(30 byte),
    company          varchar2(100 byte),
    description      varchar2(2000 byte),
    currency_id      varchar2(15 byte),
    gl_cash_account  varchar2(100 byte),
    bank_id          varchar2(100 byte),
    region           varchar2(100 byte),
    account_number   varchar2(34 byte),
    routing_number   varchar2(10 byte),
    creation_date    date default sysdate,
    last_update_date date default sysdate
);

alter table samqa.checkbook_gp
    add constraint checkbook_gp_p primary key ( checkbook_id )
        using index enable;

alter table samqa.checkbook_gp add constraint checkbook_gp_u1 unique ( checkbook_code )
    using index enable;

