-- liquibase formatted sql
-- changeset SAMQA:1754374163719 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\termination_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/termination_external.sql:null:082dd0c229b637e6e3c847607c4476ccb3dc62b7:create

create table samqa.termination_external (
    acc_num          varchar2(30 byte),
    ssn              varchar2(30 byte),
    last_name        varchar2(255 byte),
    first_name       varchar2(255 byte),
    termination_date varchar2(255 byte),
    plan_type        varchar2(255 byte),
    tpa_id           varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'terminations.bad'
            logfile 'terminations.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'inputfileTerms.csv20120112' )
) reject limit unlimited;

