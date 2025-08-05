-- liquibase formatted sql
-- changeset SAMQA:1754374161373 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\online_form_5500_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/online_form_5500_staging.sql:null:d79627dc65789489cc4da2666284a1c85a69186e:create

create table samqa.online_form_5500_staging (
    enrollment_id               number(10, 0),
    entrp_id                    number(10, 0),
    batch_number                number(10, 0),
    salesrep_flag               varchar2(1 byte),
    salesrep_id                 number(10, 0),
    send_invoice                varchar2(1 byte),
    payment_method              varchar2(100 byte),
    credit_payment_monthly_pre  varchar2(1 byte),
    bank_name                   varchar2(100 byte),
    routing_number              varchar2(100 byte),
    bank_acc_num                varchar2(20 byte),
    bank_acc_type               varchar2(100 byte),
    acct_usage                  varchar2(100 byte),
    pay_acct_fees               varchar2(100 byte),
    grand_total_price           number(10, 0),
    creation_date               date,
    created_by                  number(10, 0),
    modified_date               date,
    modified_by                 number(10, 0),
    source                      varchar2(100 byte),
    acc_num                     varchar2(50 byte),
    status                      varchar2(1 byte) default 'I',
    page_validity               varchar2(1 byte),
    company_contact_entity      varchar2(100 byte),
    company_contact_email       varchar2(100 byte),
    plan_admin_individual_name  varchar2(200 byte),
    emp_plan_sponsor_ind_name   varchar2(200 byte),
    disp_annual_report_ind_name varchar2(200 byte),
    disp_annual_report_phone_no varchar2(200 byte),
    form_5500_sub_option_flag   varchar2(200 byte),
    company_contact_others      varchar2(200 byte),
    acct_payment_fees           varchar2(100 byte),
    bank_authorize              varchar2(1 byte),
    inactive_plan_flag          varchar2(1 byte) default 'N'
);

alter table samqa.online_form_5500_staging add primary key ( enrollment_id )
    using index enable;

