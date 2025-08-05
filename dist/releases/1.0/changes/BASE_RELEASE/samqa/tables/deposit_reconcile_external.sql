-- liquibase formatted sql
-- changeset SAMQA:1754374155673 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\deposit_reconcile_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/deposit_reconcile_external.sql:null:01b03bd4f1aa1d6cbdc9b997b669adb3495694a0:create

create table samqa.deposit_reconcile_external (
    first_name    varchar2(2000 byte),
    last_name     varchar2(2000 byte),
    acc_num       varchar2(30 byte),
    check_number  varchar2(255 byte),
    check_amount  number,
    trans_date    varchar2(30 byte),
    ssn           varchar2(30 byte),
    reason_code   number,
    er_fee_amount number,
    ee_fee_amount number
)
organization external ( type oracle_loader
    default directory debit_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'deposit_reconcile.bad'
            logfile 'deposit_reconcile.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_dir : 'SNNupload.csv' )
) reject limit 1;

