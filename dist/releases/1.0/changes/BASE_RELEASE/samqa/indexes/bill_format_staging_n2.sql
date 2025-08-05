-- liquibase formatted sql
-- changeset SAMQA:1754373929718 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bill_format_staging_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bill_format_staging_n2.sql:null:d6f8cb4fed8db03147971bed5f9a0f944c38bf82:create

create index samqa.bill_format_staging_n2 on
    samqa.bill_format_staging (
        transaction_id
    );

