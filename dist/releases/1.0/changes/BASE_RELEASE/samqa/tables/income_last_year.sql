-- liquibase formatted sql
-- changeset SAMQA:1754374159526 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\income_last_year.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/income_last_year.sql:null:f1425b90281229b2065e17f6b1902815cde25391:create

create table samqa.income_last_year (
    change_num         number,
    acc_id             number(9, 0) not null enable,
    fee_date           date not null enable,
    fee_code           number(3, 0),
    amount             number(15, 2) not null enable,
    contributor        number(9, 0),
    pay_code           number(3, 0) not null enable,
    cc_number          varchar2(100 byte),
    cc_code            number(3, 0),
    cc_owner           varchar2(30 byte),
    cc_date            date,
    note               varchar2(4000 byte),
    amount_add         number(15, 2),
    cur_bal            number(15, 2),
    contributor_amount number,
    list_bill          varchar2(100 byte),
    transaction_type   varchar2(1 byte),
    debit_card_posted  varchar2(1 byte),
    ee_fee_amount      number,
    er_fee_amount      number,
    created_by         number,
    creation_date      date,
    last_updated_by    number,
    last_updated_date  date
);

