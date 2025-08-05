-- liquibase formatted sql
-- changeset SAMQA:1754374152401 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\beneficiary_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/beneficiary_external.sql:null:1cfb932de5d3648dc35a0fe95bcdb65a36116bf4:create

create table samqa.beneficiary_external (
    beneficiary_id   number,
    beneficiary_name varchar2(255 byte),
    beneficiary_type number,
    relat_code       varchar2(255 byte),
    effective_date   varchar2(12 byte),
    pers_id          varchar2(255 byte),
    creation_date    varchar2(12 byte),
    distribution     number,
    acct_id          varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' missing field values are null
    ) location ( 'Online_Enroll_Ben.csv' )
) reject limit unlimited;

