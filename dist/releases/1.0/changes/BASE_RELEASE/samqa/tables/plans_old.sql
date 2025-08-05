-- liquibase formatted sql
-- changeset SAMQA:1754374162426 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\plans_old.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/plans_old.sql:null:0cb44479a47da80210531b857eb21e9168cef975:create

create table samqa.plans_old (
    plan_code    number(3, 0) not null enable,
    plan_name    varchar2(100 byte) not null enable,
    plan_sign    varchar2(3 byte),
    note         varchar2(4000 byte),
    entrp_id     number,
    account_type varchar2(10 byte)
);

