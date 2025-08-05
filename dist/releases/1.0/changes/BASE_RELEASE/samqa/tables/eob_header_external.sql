-- liquibase formatted sql
-- changeset SAMQA:1754374157686 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_header_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_header_external.sql:null:c51b61c6ff3d6c58ced76366b052a853953cb45c:create

create table samqa.eob_header_external (
    tpa_user_id        number,
    eob_id             varchar2(255 byte),
    action             varchar2(20 byte),
    status             varchar2(255 byte),
    claim_number       varchar2(255 byte),
    service_date_from  varchar2(255 byte),
    provider_name      varchar2(255 byte),
    provider_id        number,
    insplan_id         number,
    company_id         number,
    creation_date      varchar2(255 byte),
    last_update_date   varchar2(255 byte),
    patient_first_name varchar2(100 byte),
    patient_last_name  varchar2(100 byte)
)
organization external ( type oracle_loader
    default directory eob_dir access parameters (
        records delimited by newline
            badfile 'eob_header.bad'
            logfile 'eob_header.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( eob_dir : 'HEx_head_9180_2716163204.csv' )
) reject limit unlimited;

