-- liquibase formatted sql
-- changeset SAMQA:1754374159490 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\income.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/income.sql:null:a9c151c5ad4f7b8b9563563f5749a9145c735523:create

create table samqa.income (
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
    amount_add         number(15, 2) default 0,
    cur_bal            number(15, 2),
    contributor_amount number,
    list_bill          varchar2(100 byte),
    transaction_type   varchar2(1 byte) default 'A',
    debit_card_posted  varchar2(1 byte) default 'N',
    ee_fee_amount      number,
    er_fee_amount      number,
    created_by         number,
    creation_date      date,
    last_updated_by    number,
    last_updated_date  date,
    plan_type          varchar2(30 byte),
    orig_doc_ref       varchar2(1000 byte),
    gp_posted          varchar2(2 byte),
    due_date           date,
    postmark_date      date
);

create unique index samqa.income_pk on
    samqa.income (
        change_num
    );

alter table samqa.income
    add constraint income_pk
        primary key ( change_num )
            using index samqa.income_pk enable;

