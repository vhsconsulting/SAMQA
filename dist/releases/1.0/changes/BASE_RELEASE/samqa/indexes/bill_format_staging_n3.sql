-- liquibase formatted sql
-- changeset SAMQA:1754373929727 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bill_format_staging_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bill_format_staging_n3.sql:null:1935e1e1c48799d69a61d1631f9d5c30c343f339:create

create index samqa.bill_format_staging_n3 on
    samqa.bill_format_staging (
        grp_acc_id
    );

