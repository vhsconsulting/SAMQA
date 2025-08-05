-- liquibase formatted sql
-- changeset SAMQA:1754374159659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\investment_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/investment_staging.sql:null:400ffa801f6b821dafd1f41a2e223776eeb80b37:create

create table samqa.investment_staging (
    batch_number       number,
    invest_id          number,
    investment_acc_num varchar2(20 byte),
    first_name         varchar2(255 byte),
    last_name          varchar2(255 byte),
    ticker_name        varchar2(100 byte),
    market_date        varchar2(30 byte),
    market_value       number,
    investment_amount  number,
    acc_id             number,
    process_status     varchar2(1 byte),
    process_message    varchar2(300 byte),
    creation_date      date,
    created_by         number,
    last_update_date   date,
    last_updated_by    number
);

