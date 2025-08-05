-- liquibase formatted sql
-- changeset SAMQA:1754374154668 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_settlement_error.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_settlement_error.sql:null:f78fba16d3ebe83fbf152b46ce5d04beadefa21f:create

create table samqa.debit_settlement_error (
    ssn              varchar2(30 byte),
    acc_num          varchar2(30 byte),
    pers_id          number,
    record_type      varchar2(30 byte),
    error_message    varchar2(3200 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

