-- liquibase formatted sql
-- changeset SAMQA:1754374161983 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\payment_acc_info.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/payment_acc_info.sql:null:ed440feb4dd376c24ca2dffe99ea22999f2e3b4c:create

create table samqa.payment_acc_info (
    account_id       number,
    account_num      varchar2(30 byte),
    account_type     varchar2(30 byte),
    description      varchar2(255 byte),
    status           varchar2(1 byte) default 'A',
    creation_date    date default sysdate,
    last_update_date date default sysdate
);

