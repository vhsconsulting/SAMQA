-- liquibase formatted sql
-- changeset SAMQA:1754374152494 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bill_format_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bill_format_staging.sql:null:f3a8890e6fc04dc0808beecdf34de23a3ee87b56:create

create table samqa.bill_format_staging (
    tpa_id           varchar2(100 byte),
    group_name       varchar2(100 byte),
    group_acc_num    varchar2(100 byte),
    first_name       varchar2(100 byte),
    last_name        varchar2(100 byte),
    ssn              varchar2(100 byte),
    contrb_type      varchar2(100 byte),
    er_contrb        varchar2(100 byte),
    ee_contrb        varchar2(100 byte),
    er_fee_contrb    varchar2(100 byte),
    ee_fee_contrb    varchar2(100 byte),
    total_contrb_amt varchar2(100 byte),
    bank_name        varchar2(100 byte),
    bank_routing_num varchar2(100 byte),
    bank_acct_num    varchar2(100 byte),
    grp_acc_id       varchar2(100 byte),
    emp_acc_id       varchar2(100 byte),
    emp_acc_num      varchar2(100 byte),
    account_type     varchar2(100 byte),
    transaction_id   varchar2(100 byte),
    error_message    varchar2(2000 byte),
    error_column     varchar2(20 byte),
    batch_number     number,
    creation_date    date default sysdate,
    created_by       varchar2(30 byte),
    last_update_date date default sysdate,
    last_updated_by  varchar2(30 byte)
);

