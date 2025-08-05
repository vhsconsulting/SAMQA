-- liquibase formatted sql
-- changeset SAMQA:1754374153534 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claims_takeover_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claims_takeover_external.sql:null:845f826ac433f869301a74391eb1017a57ef7d14:create

create table samqa.claims_takeover_external (
    acc_num           varchar2(15 byte),
    service_plan_type varchar2(5 byte),
    claim_amount      varchar2(15 byte),
    service_start_dt  varchar2(15 byte),
    service_end_dt    varchar2(15 byte),
    note              varchar2(50 byte),
    takeover_flag     varchar2(5 byte)
)
organization external ( type oracle_loader
    default directory claim_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( claim_dir : 'Sterling_HRAFSA_Takeover_Claim_Template.csv' )
) reject limit 1;

