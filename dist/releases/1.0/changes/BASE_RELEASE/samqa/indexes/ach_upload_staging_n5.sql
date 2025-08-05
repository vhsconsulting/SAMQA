-- liquibase formatted sql
-- changeset SAMQA:1754373928962 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_upload_staging_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_upload_staging_n5.sql:null:e03f9f51c258574a37b5bf95b85325b4b61ad3ae:create

create index samqa.ach_upload_staging_n5 on
    samqa.ach_upload_staging (
        bank_name,
        bank_routing_num,
        bank_acct_num
    );

