-- liquibase formatted sql
-- changeset SAMQA:1754374152511 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\blocked_accounts_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/blocked_accounts_mv.sql:null:a9985fc3ce12019c3f84ba0d11be9ad8e408d305:create

create table samqa.blocked_accounts_mv (
    acc_num    varchar2(20 byte) not null disable,
    user_name  varchar2(12 byte),
    acc_id     number(9, 0) not null disable,
    pers_id    number(9, 0) not null disable,
    first_name varchar2(50 byte),
    last_name  varchar2(50 byte) not null disable,
    ssn        varchar2(20 byte),
    address    varchar2(100 byte),
    city       varchar2(30 byte),
    state      varchar2(2 byte),
    zip        varchar2(10 byte),
    drivlic    varchar2(20 byte),
    phone_day  varchar2(100 byte),
    email      varchar2(100 byte)
);

