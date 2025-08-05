-- liquibase formatted sql
-- changeset SAMQA:1754374160064 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\list_format_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/list_format_external.sql:null:f6e461f261a57e586810f33fbee06fa88cd0b642:create

create table samqa.list_format_external (
    first_name    varchar2(100 byte),
    last_name     varchar2(100 byte),
    acc_num       varchar2(100 byte),
    ee_contrb     varchar2(100 byte),
    ee_fee_contrb varchar2(100 byte),
    er_contrb     varchar2(100 byte),
    er_fee_contrb varchar2(100 byte),
    reason_code   varchar2(100 byte),
    note          varchar2(100 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'enroll.bad'
            logfile 'enroll.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'RolloverHR4.csv' )
) reject limit 0;

