-- liquibase formatted sql
-- changeset SAMQA:1754374156466 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_payments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_payments.sql:null:066faeb4866bbff604fbc1cd40803f59adaf6a54:create

create table samqa.employer_payments (
    employer_payment_id   number,
    entrp_id              number,
    check_amount          number,
    check_number          varchar2(255 byte),
    check_date            date,
    creation_date         date,
    created_by            number,
    last_update_date      date,
    last_updated_by       number,
    note                  varchar2(3200 byte),
    bank_acct_id          number,
    payment_register_id   number,
    list_bill             varchar2(255 byte),
    reason_code           number,
    transaction_date      date,
    plan_type             varchar2(30 byte),
    pay_code              number,
    transaction_source    varchar2(30 byte),
    plan_start_date       date,
    plan_end_date         date,
    memo                  varchar2(255 byte),
    invoice_id            number,
    pay_source            varchar2(30 byte),
    refund_type           varchar2(30 byte),
    refund_reason         varchar2(100 byte),
    gp_posted             varchar2(2 byte),
    vendor_id             number,
    cobra_disbursement_id number,
    show_online_flag      varchar2(1 byte) default 'Y',
    paid_by               varchar2(30 byte),
    payment_status        varchar2(30 byte) default 'PENDING',
    internal_note         varchar2(3200 byte)
);

