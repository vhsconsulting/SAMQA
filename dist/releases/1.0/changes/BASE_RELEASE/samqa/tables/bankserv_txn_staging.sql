-- liquibase formatted sql
-- changeset SAMQA:1754374152041 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bankserv_txn_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bankserv_txn_staging.sql:null:97b9be4df68265983979d192bb2a17c71e046701:create

create table samqa.bankserv_txn_staging (
    record_id          number,
    company_number     varchar2(100 byte),
    routing_num        varchar2(100 byte),
    acc_number         varchar2(100 byte),
    check_number       varchar2(100 byte),
    check_date         varchar2(100 byte),
    return_date        varchar2(100 byte),
    amount             varchar2(100 byte),
    reference_number   varchar2(100 byte),
    origin             varchar2(100 byte),
    created_by_file    varchar2(100 byte),
    return_code        varchar2(255 byte),
    rtn                varchar2(255 byte),
    rtn_queue          varchar2(255 byte),
    status             varchar2(100 byte),
    cust_id            varchar2(100 byte),
    cust_ref_num       varchar2(100 byte),
    first_name         varchar2(100 byte),
    last_name          varchar2(100 byte),
    product_type       varchar2(100 byte),
    batch_number       number,
    transaction_type   varchar2(10 byte),
    transaction_id     varchar2(100 byte),
    acc_num            varchar2(100 byte),
    contributor        varchar2(100 byte),
    error_column       varchar2(10 byte),
    error_message      varchar2(1000 byte),
    creation_date      date default sysdate,
    created_by         varchar2(30 byte),
    last_update_date   date default sysdate,
    last_updated_by    varchar2(30 byte),
    employer_name      varchar2(2000 byte),
    processed          varchar2(1 byte),
    transaction_entity varchar2(100 byte)
);

