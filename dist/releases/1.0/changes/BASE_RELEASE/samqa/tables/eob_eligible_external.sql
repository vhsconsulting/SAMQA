-- liquibase formatted sql
-- changeset SAMQA:1754374157610 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_eligible_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_eligible_external.sql:null:292db78b2ba7f87858f1f68067a20466190f60a3:create

create table samqa.eob_eligible_external (
    account_no     varchar2(100 byte),
    member_id      varchar2(100 byte),
    ssn            varchar2(20 byte),
    emp_last_name  varchar2(255 byte),
    emp_first_name varchar2(255 byte),
    emp_dob        varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory eob_dir access parameters (
        records delimited by newline
            badfile 'eob_eligible.bad'
            logfile 'eob_eligible.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'TestEligibilityfile20131210.csv' )
) reject limit unlimited;

