-- liquibase formatted sql
-- changeset SAMQA:1754374160829 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\monthly_invoice_payment_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/monthly_invoice_payment_detail.sql:null:2a2ce396edbe6ef9c0df43e76c12aff2f27c3e87:create

create table samqa.monthly_invoice_payment_detail (
    entrp_id               number,
    source                 varchar2(50 byte),
    payment_method         varchar2(30 byte),
    bank_acct_id           number,
    charged_to             varchar2(30 byte),
    plan_start_date        date,
    plan_end_date          date,
    status                 varchar2(1 byte) default 'A',
    note                   varchar2(4000 byte),
    monthly_payment_seq_no number,
    creation_date          date,
    created_by             number,
    last_update_date       date,
    last_updated_by        number
);

