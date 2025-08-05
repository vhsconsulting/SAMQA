-- liquibase formatted sql
-- changeset SAMQA:1754374158436 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fauth.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fauth.sql:null:cff771c173a4601dca05fc74d252d58d31222b20:create

create table samqa.fauth (
    client_id     varchar2(10 byte),
    ppdb          varchar2(5 byte),
    client_name   varchar2(20 byte),
    ssn           varchar2(11 byte) not null enable,
    description   varchar2(50 byte),
    amount        number(15, 2),
    swipe_time    varchar2(20 byte),
    merchant_code varchar2(10 byte),
    log_id        varchar2(20 byte),
    purse_type    varchar2(3 byte),
    purse_year    number(4, 0)
);

