-- liquibase formatted sql
-- changeset SAMQA:1754374163056 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\scheduler_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/scheduler_external.sql:null:162e1f4f4824aa0b6245421346656433f9522824:create

create table samqa.scheduler_external (
    acc_num         varchar2(20 byte),
    ssn             varchar2(20 byte),
    employer_amount varchar2(15 byte),
    employee_amount varchar2(15 byte),
    employer_fee    varchar2(15 byte),
    employee_fee    varchar2(50 byte),
    note            varchar2(3200 byte),
    er_acc_num      varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory debit_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_dir : 'Scheduler Details Export.csv' )
) reject limit unlimited;

