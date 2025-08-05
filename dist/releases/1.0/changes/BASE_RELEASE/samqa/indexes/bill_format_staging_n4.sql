-- liquibase formatted sql
-- changeset SAMQA:1754373929736 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bill_format_staging_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bill_format_staging_n4.sql:null:e3336d27b1fae629ff865aa9511fa078e4d9143d:create

create index samqa.bill_format_staging_n4 on
    samqa.bill_format_staging (
        emp_acc_id,
        emp_acc_num
    );

