-- liquibase formatted sql
-- changeset SAMQA:1754373929746 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bill_format_staging_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bill_format_staging_n5.sql:null:9ea6e958c018831470378e8617377d0ab5f56009:create

create index samqa.bill_format_staging_n5 on
    samqa.bill_format_staging (
        bank_name,
        bank_routing_num,
        bank_acct_num
    );

