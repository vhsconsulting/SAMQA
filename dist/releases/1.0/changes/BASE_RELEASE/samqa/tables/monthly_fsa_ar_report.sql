-- liquibase formatted sql
-- changeset SAMQA:1754374160814 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_fsa_ar_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_fsa_ar_report.sql:null:dd3af8f9f58b6f4e03d68ffea798ba875d422360:create

create table samqa.monthly_fsa_ar_report (
    "Invoice Number"     varchar2(30 byte),
    "Invoice #"          number not null enable,
    "Employer Name"      varchar2(4000 byte),
    "Start Date"         varchar2(10 byte),
    "End Date"           varchar2(10 byte),
    "Invoice Date"       varchar2(10 byte),
    "Invoice Due Date"   varchar2(10 byte),
    "Approved Date"      varchar2(10 byte),
    "Void Date"          varchar2(10 byte),
    "Invoice Amount"     varchar2(4000 byte),
    "Paid Amount"        varchar2(4000 byte),
    "Pending Amount"     varchar2(4000 byte),
    "Refund Amount"      varchar2(4000 byte),
    "Invoice Term"       varchar2(255 byte),
    "Payment Method"     varchar2(255 byte),
    "Billing Name"       varchar2(257 byte),
    "Billing Attn"       varchar2(257 byte),
    "Billing Address"    varchar2(1025 byte),
    "Account Type"       varchar2(30 byte),
    "Reason Name"        varchar2(100 byte) not null enable,
    "Total Line Amount"  varchar2(4000 byte),
    "Voided Line Amount" varchar2(4000 byte),
    "Effective Date"     varchar2(10 byte),
    "Status"             varchar2(11 byte),
    "Client Service Rep" varchar2(4000 byte),
    "Stacked Account"    varchar2(4000 byte),
    "Invoice Line Type"  varchar2(4000 byte),
    status               varchar2(4000 byte),
    salesrep             varchar2(4000 byte)
)
    parallel;

