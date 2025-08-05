-- liquibase formatted sql
-- changeset SAMQA:1754374153507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claims_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claims_external.sql:null:e0495f7ef912dfe0ee5664af6106761e2e8b7917:create

create table samqa.claims_external (
    tpa_id               varchar2(15 byte),
    claim_number         varchar2(25 byte),
    member_id            varchar2(15 byte),
    service_plan_type    varchar2(5 byte),
    claim_amount         varchar2(15 byte),
    provider_name        varchar2(50 byte),
    patient_name         varchar2(50 byte),
    service_start_dt     varchar2(15 byte),
    service_end_dt       varchar2(15 byte),
    note                 varchar2(50 byte),
    other_insurance      varchar2(50 byte),
    provider_flag        varchar2(1 byte),
    check_ach_flag       varchar2(5 byte),
    eob_required_ind     varchar2(1 byte),
    insurance_category   varchar2(50 byte),
    expense_category     varchar2(50 byte),
    address              varchar2(50 byte),
    city                 varchar2(25 byte),
    state                varchar2(2 byte),
    zip                  varchar2(10 byte),
    provider_acct_number varchar2(25 byte),
    bank_name            varchar2(25 byte),
    bank_acct_number     varchar2(20 byte),
    routing_number       varchar2(20 byte)
)
organization external ( type oracle_loader
    default directory claim_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( claim_dir : 'Firmenich Claim Upload File 04-01-25.csv' )
) reject limit unlimited;

