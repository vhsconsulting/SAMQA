-- liquibase formatted sql
-- changeset SAMQA:1754374152471 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bill_format_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bill_format_external.sql:null:43eadbac44909ffe8fc2cc5c5685a89bbf9079a3:create

create table samqa.bill_format_external (
    tpa_id           varchar2(100 byte),
    group_name       varchar2(100 byte),
    group_id         varchar2(100 byte),
    first_name       varchar2(100 byte),
    last_name        varchar2(100 byte),
    ssn              varchar2(100 byte),
    contrb_type      varchar2(100 byte),
    er_contrb        varchar2(100 byte),
    ee_contrb        varchar2(100 byte),
    er_fee_contrb    varchar2(100 byte),
    ee_fee_contrb    varchar2(100 byte),
    total_contrb_amt varchar2(100 byte),
    bank_name        varchar2(100 byte),
    bank_routing_num varchar2(100 byte),
    bank_acct_num    varchar2(100 byte),
    account_type     varchar2(10 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'ach_transfer.bad'
            logfile 'ach_transfer.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'legacy_12182011.csv' )
) reject limit 0;

