-- liquibase formatted sql
-- changeset SAMQA:1754374153657 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_disbursement_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_disbursement_detail.sql:null:9e4e112559b79236f2f9bc7389a24dc73476ee84:create

create table samqa.cobra_disbursement_detail (
    cobra_disburse_det_id number,
    division_id           number,
    division_name         varchar2(100 byte),
    memberid              number,
    qb_first_name         varchar2(255 byte),
    qb_last_name          varchar2(255 byte),
    carrier_name          varchar2(1000 byte),
    plan_name             varchar2(1000 byte),
    policy_number         varchar2(1000 byte),
    carrier_first_name    varchar2(1000 byte),
    carrier_last_name     varchar2(1000 byte),
    carrier_phone         varchar2(1000 byte),
    carrier_address1      varchar2(1000 byte),
    carrier_address2      varchar2(1000 byte),
    carrier_city          varchar2(1000 byte),
    carrier_state         varchar2(1000 byte),
    carrier_postal_code   varchar2(1000 byte),
    active                varchar2(10 byte),
    payment_source        varchar2(100 byte),
    premium_amount        number,
    premium_start_date    date,
    premium_end_date      date,
    creation_date         date default sysdate,
    created_by            number,
    last_update_date      date default sysdate,
    last_updated_by       number,
    deposit_date          date,
    premium_due_date      date,
    client_id             number,
    client_name           varchar2(255 byte),
    cobra_disbursement_id number,
    allocated_amount      number,
    admin_fee             number,
    adjusted_premium      number
);

alter table samqa.cobra_disbursement_detail add primary key ( cobra_disburse_det_id )
    using index enable;

