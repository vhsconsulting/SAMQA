-- liquibase formatted sql
-- changeset SAMQA:1754374153953 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_plan_setup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_plan_setup.sql:null:e6a55587647bc61e753c0017553330197837edb3:create

create table samqa.cobra_plan_setup (
    cobra_plan_id           number,
    entity_id               number,
    plan_name               varchar2(100 byte),
    plan_type               varchar2(100 byte),
    plan_number             varchar2(100 byte),
    policy_number           varchar2(100 byte),
    insurance_company_name  varchar2(100 byte),
    governing_state         varchar2(100 byte),
    plan_start_date         date,
    plan_end_date           date,
    self_funded_flag        varchar2(10 byte),
    conversion_flag         varchar2(10 byte),
    bill_cobra_premium_flag varchar2(10 byte),
    coverage_terminate      varchar2(100 byte),
    age_rated_flag          varchar2(10 byte),
    carrier_contact_name    varchar2(100 byte),
    carrier_contact_email   varchar2(100 byte),
    carrier_phone_no        varchar2(100 byte),
    carrier_addr            varchar2(1000 byte),
    ee_premium              varchar2(10 byte),
    ee_spouse_premium       varchar2(10 byte),
    ee_child_premium        varchar2(10 byte),
    ee_children_premium     varchar2(10 byte),
    ee_family_premium       varchar2(10 byte),
    spouse_premium          varchar2(10 byte),
    chil_premium            varchar2(10 byte),
    spouse_child_premium    varchar2(10 byte),
    salesrep_flag           varchar2(10 byte),
    salesrep_id             varchar2(10 byte),
    description             varchar2(1000 byte),
    created_by              number,
    creation_date           date default sysdate,
    last_updated_by         number,
    last_update_date        date default sysdate,
    ben_plan_id             number,
    cobra_fed_flag          varchar2(1 byte)
);

alter table samqa.cobra_plan_setup add primary key ( cobra_plan_id )
    using index enable;

