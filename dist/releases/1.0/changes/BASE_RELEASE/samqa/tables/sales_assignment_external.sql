-- liquibase formatted sql
-- changeset SAMQA:1754374162685 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_assignment_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_assignment_external.sql:null:bc46651b2c99261e43e0a0f6c9b2eb13bafd1e87:create

create table samqa.sales_assignment_external (
    acc_num        varchar2(100 byte),
    sales_rep_name varchar2(1000 byte),
    effective_date varchar2(1000 byte),
    salesrep_role  varchar2(50 byte)
)
organization external ( type oracle_loader
    default directory report_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'salesrep.bad'
            logfile 'salesrep.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null reject rows with all null fields
    ) location ( report_dir : 'Salesrep_upload_template (4) sd.csv' )
) reject limit 0;

