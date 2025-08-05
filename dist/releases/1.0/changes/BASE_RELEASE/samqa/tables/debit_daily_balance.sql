-- liquibase formatted sql
-- changeset SAMQA:1754374154583 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_daily_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_daily_balance.sql:null:072afda8a08bb1d044b6153c3839ee4c928c03a5:create

create table samqa.debit_daily_balance (
    ssn        varchar2(20 byte) not null enable,
    card_value number(15, 2)
);

alter table samqa.debit_daily_balance add primary key ( ssn )
    using index enable;

