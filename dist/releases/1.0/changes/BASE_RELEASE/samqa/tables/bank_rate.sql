-- liquibase formatted sql
-- changeset SAMQA:1754374151955 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bank_rate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bank_rate.sql:null:30958e1593da439e2991906aa6bc0ddaed2eb17b:create

create table samqa.bank_rate (
    bank_rate_id   number,
    entrp_id       number,
    bank_code      varchar2(3 byte),
    low_balance    number,
    high_balance   number,
    contract_date  date,
    effective_date date,
    interest_rate  number,
    apr            number,
    active         number,
    notes          varchar2(3200 byte)
);

