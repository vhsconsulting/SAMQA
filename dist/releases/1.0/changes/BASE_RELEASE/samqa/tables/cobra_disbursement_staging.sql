-- liquibase formatted sql
-- changeset SAMQA:1754374153688 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_disbursement_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_disbursement_staging.sql:null:ba7b0b70319857185a7587c8d77b8a1b64f21a3f:create

create table samqa.cobra_disbursement_staging (
    cobra_disburse_stage_id number,
    client_id               number,
    client_name             varchar2(1000 byte),
    division_id             number,
    division_name           varchar2(100 byte),
    memberid                number,
    qb_first_name           varchar2(255 byte),
    qb_last_name            varchar2(255 byte),
    carrier_name            varchar2(1000 byte),
    plan_name               varchar2(1000 byte),
    policy_number           varchar2(1000 byte),
    carrier_first_name      varchar2(1000 byte),
    carrier_last_name       varchar2(1000 byte),
    carrier_phone           varchar2(1000 byte),
    carrier_address1        varchar2(1000 byte),
    carrier_address2        varchar2(1000 byte),
    carrier_city            varchar2(1000 byte),
    carrier_state           varchar2(1000 byte),
    carrier_postal_code     varchar2(1000 byte),
    active                  varchar2(10 byte),
    payment_source          varchar2(100 byte),
    premium_amount          number,
    premium_start_date      date,
    premium_end_date        date,
    deposit_date            date,
    premiumduedate          date,
    creation_date           date default sysdate,
    created_by              number,
    last_update_date        date default sysdate,
    last_updated_by         number,
    cobra_disbursement_id   number,
    allocated_amount        number,
    admin_fee               number,
    clientgroup_id          varchar2(100 byte),
    entrp_id                number,
    postmark_date           date,
    qbpaymentid             number
);

alter table samqa.cobra_disbursement_staging add primary key ( cobra_disburse_stage_id )
    using index enable;

