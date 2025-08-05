-- liquibase formatted sql
-- changeset SAMQA:1754374151671 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_invoice_dist_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_invoice_dist_plans.sql:null:f0c9b078444767c053dc928093a2b759033fd12e:create

create table samqa.ar_invoice_dist_plans (
    invoice_dist_plan_id number not null enable,
    invoice_id           number,
    entrp_id             number,
    acc_id               number,
    dependent_id         number,
    pers_id              number,
    account_status       varchar2(30 byte),
    plan_status          varchar2(30 byte),
    plan_code            varchar2(30 byte),
    plan_type            varchar2(30 byte),
    effective_date       date,
    termination_date     date,
    termination_req_date date,
    renewal_date         date,
    terminated           varchar2(1 byte),
    enrolled_date        date,
    invoice_reason       varchar2(30 byte),
    invoice_days         number,
    creation_date        date default sysdate,
    created_by           number,
    last_update_date     date default sysdate,
    last_updated_by      number,
    invoice_kind         varchar2(25 byte),
    termed_date          date,
    start_date           date,
    end_date             date,
    product_type         varchar2(30 byte),
    division_code        varchar2(30 byte)
);

alter table samqa.ar_invoice_dist_plans add primary key ( invoice_dist_plan_id )
    using index enable;

