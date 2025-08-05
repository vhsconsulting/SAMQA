-- liquibase formatted sql
-- changeset SAMQA:1754374162070 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\payroll_scheduler_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/payroll_scheduler_external.sql:null:00e12efe06e73e4daae6e903e199618680ebdf31:create

create table samqa.payroll_scheduler_external (
    first_name      varchar2(255 byte),
    last_name       varchar2(255 byte),
    ssn             varchar2(30 byte),
    employee_amount varchar2(15 byte),
    employee_fee    varchar2(50 byte),
    employer_amount varchar2(15 byte),
    employer_fee    varchar2(15 byte),
    reason_name     varchar2(3200 byte),
    note            varchar2(3200 byte),
    payroll_date    varchar2(30 byte),
    plan_type       varchar2(30 byte),
    er_acc_num      varchar2(20 byte),
    pay_frequency   varchar2(300 byte)
)
organization external ( type oracle_loader
    default directory scheduler_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( scheduler_dir : '2025-04-244SManufacturingTexasLLCDBAEastTexasPrecast_FSA_Contribution_04242025.csv' )
) reject limit unlimited;

