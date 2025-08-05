-- liquibase formatted sql
-- changeset SAMQA:1754374153758 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_disbursement_staging_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_disbursement_staging_bkp.sql:null:d4c495456ff83160a17e7a5486f0096cfa633854:create

create table samqa.cobra_disbursement_staging_bkp (
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
    creation_date           date,
    created_by              number,
    last_update_date        date,
    last_updated_by         number,
    cobra_disbursement_id   number,
    allocated_amount        number,
    admin_fee               number,
    clientgroup_id          varchar2(100 byte),
    entrp_id                number,
    postmark_date           date,
    qbpaymentid             number
);

