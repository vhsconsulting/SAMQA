-- liquibase formatted sql
-- changeset SAMQA:1754374153843 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_disbursements_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_disbursements_bkp.sql:null:d200b734977dad9c0ad3c0614be3d3203ea2324b:create

create table samqa.cobra_disbursements_bkp (
    cobra_disbursement_id  number,
    client_id              number,
    client_name            varchar2(1000 byte),
    division_id            number,
    division_name          varchar2(100 byte),
    payment_source         varchar2(100 byte),
    premium_amount         number,
    premium_start_date     date,
    premium_end_date       date,
    remittance_first_name  varchar2(1000 byte),
    remittance_last_name   varchar2(1000 byte),
    remittance_phone       varchar2(1000 byte),
    remittance_address1    varchar2(1000 byte),
    remittance_address2    varchar2(1000 byte),
    remittance_city        varchar2(1000 byte),
    remittance_state       varchar2(1000 byte),
    remittance_postal_code varchar2(1000 byte),
    creation_date          date,
    created_by             number,
    last_update_date       date,
    last_updated_by        number,
    clientgroup_id         varchar2(100 byte),
    entrp_id               number,
    acc_num                varchar2(30 byte),
    remittance_start_date  date,
    remittance_end_date    date,
    adjusted_premium       number,
    employer_payment_id    number,
    remittance_code        number
);

