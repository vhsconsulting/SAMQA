-- liquibase formatted sql
-- changeset SAMQA:1754374154491 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_card_adjust.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_card_adjust.sql:null:82e101057bd3e638eca22b651b54a22affd2dcb3:create

create table samqa.debit_card_adjust (
    acc_num        varchar2(20 byte) not null enable,
    acc_id         number(9, 0) not null enable,
    pers_id        number(9, 0),
    card_limit     number(15, 2),
    card_value     number(15, 2),
    curr_acct_bal  number(15, 2),
    card_value_new number(15, 2),
    bal_adjust     number(15, 2),
    ssn            varchar2(9 byte)
);

alter table samqa.debit_card_adjust add primary key ( acc_num )
    using index enable;

