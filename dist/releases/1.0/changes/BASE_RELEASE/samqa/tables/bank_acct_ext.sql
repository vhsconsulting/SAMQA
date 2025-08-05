-- liquibase formatted sql
-- changeset SAMQA:1754374151943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bank_acct_ext.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bank_acct_ext.sql:null:fdc96b037f6cff1387a41694e88bdb9c749af1ff:create

create table samqa.bank_acct_ext (
    tpa_id           varchar2(255 byte),
    ssn              varchar2(30 byte),
    account_number   varchar2(255 byte),
    bank_name        varchar2(255 byte),
    bank_acct_type   varchar2(2 byte),
    bank_routing_num varchar2(9 byte),
    bank_acct_num    varchar2(20 byte),
    account_type     varchar2(20 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( online_enroll_dir : 'bank_upload.csv' )
) reject limit 0;

