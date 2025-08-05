-- liquibase formatted sql
-- changeset SAMQA:1754374154566 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_card_updates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_card_updates.sql:null:36bb767b89662494f48abe17d4d4c411a3119e76:create

create table samqa.debit_card_updates (
    update_id         number(9, 0) not null enable,
    pers_id           number(9, 0) not null enable,
    first_name        varchar2(255 byte),
    middle_name       varchar2(1 byte),
    last_name         varchar2(50 byte),
    ssn_oldval        varchar2(20 byte),
    ssn_newval        varchar2(20 byte),
    address           varchar2(100 byte),
    city              varchar2(100 byte),
    state             varchar2(2 byte),
    zip               varchar2(10 byte),
    acc_num           varchar2(20 byte),
    date_changed      date,
    acc_num_changed   char(1 byte) not null enable,
    acc_num_processed char(1 byte) not null enable,
    demo_changed      char(1 byte) not null enable,
    demo_processed    char(1 byte) not null enable,
    old_acc_num       varchar2(30 byte)
);

