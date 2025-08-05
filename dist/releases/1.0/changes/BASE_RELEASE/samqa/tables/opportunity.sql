-- liquibase formatted sql
-- changeset SAMQA:1754374161659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\opportunity.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/opportunity.sql:null:51bbb3d663219da689bf12ed2fc87cedff42129d:create

create table samqa.opportunity (
    opp_id                   number not null enable,
    acc_id                   number not null enable,
    description              varchar2(4000 byte),
    implementation_stage_cde varchar2(10 byte),
    assigned_dept            varchar2(255 byte),
    email_pref               varchar2(50 byte),
    created_date             date not null enable,
    created_by               number not null enable,
    assigned_emp_id          number,
    opportunity_type         varchar2(20 byte),
    verified_date            date,
    current_plan_year        varchar2(100 byte),
    plan_number              varchar2(50 byte),
    closed_date              date,
    last_updated_date        date,
    last_updated_by          number,
    status                   varchar2(20 byte) not null enable,
    ben_plan_id              number,
    plan_start_date          date,
    plan_end_date            date,
    plan_type                varchar2(30 byte),
    product_type             varchar2(30 byte),
    plan_name                varchar2(100 byte),
    expec_closed_date        date,
    submission_date          date,
    dol_due_date             date,
    extension_field          varchar2(255 byte),
    extended_due_date        date,
    form_5500_field          varchar2(255 byte),
    send_plan_docs_to        varchar2(200 byte),
    invoice_to               varchar2(20 byte),
    plan_doc_sent_to_client  date,
    crm_id                   number,
    broker_information       varchar2(255 byte),
    hra_type                 varchar2(20 byte)
);

alter table samqa.opportunity
    add constraint opportunity_pk primary key ( opp_id )
        using index enable;

