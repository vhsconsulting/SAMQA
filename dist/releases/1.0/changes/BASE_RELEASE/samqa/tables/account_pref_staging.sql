-- liquibase formatted sql
-- changeset SAMQA:1754374151015 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\account_pref_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/account_pref_staging.sql:null:85872a218ca3902e61db83fcc20421d32c84c969:create

create table samqa.account_pref_staging (
    batch_number             number,
    entrp_id                 number,
    allow_broker_plan_amend  varchar2(1 byte),
    allow_bro_upd_pln_doc    varchar2(3 byte),
    allow_broker_renewal     varchar2(3 byte),
    allow_broker_enroll_rpts varchar2(1 byte),
    allow_broker_enroll      varchar2(3 byte),
    allow_broker_invoice     varchar2(3 byte),
    allow_broker_enroll_ee   varchar2(1 byte),
    allow_broker_ee          varchar2(1 byte),
    source                   varchar2(50 byte),
    creation_date            date,
    created_by               number,
    last_update_date         date,
    last_updated_by          number
);

