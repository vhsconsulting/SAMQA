-- liquibase formatted sql
-- changeset SAMQA:1754374151087 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ach_emp_detail_ext.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ach_emp_detail_ext.sql:null:2307c555f5ffc3b7ce0feca48a099371ea5c9bf6:create

create table samqa.ach_emp_detail_ext (
    transaction_id   number,
    group_id         varchar2(12 byte),
    acct_id          varchar2(12 byte),
    employer_contrib number,
    employee_contrib number,
    transaction_date varchar2(20 byte),
    date_updated     varchar2(20 byte),
    date_created     varchar2(20 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( online_enroll_dir : 'ach_transfer_details.csv' )
) reject limit unlimited;

