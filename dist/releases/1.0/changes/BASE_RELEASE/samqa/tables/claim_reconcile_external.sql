-- liquibase formatted sql
-- changeset SAMQA:1754374153384 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_reconcile_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_reconcile_external.sql:null:489d8f529cc4395ceaff4d2ca85edbfcd661bfc8:create

create table samqa.claim_reconcile_external (
    check_num  varchar2(30 byte),
    check_date varchar2(255 byte),
    acc_num    varchar2(30 byte),
    name       varchar2(300 byte),
    amount     number
)
organization external ( type oracle_loader
    default directory debit_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'claim.csv' )
) reject limit 1;

