-- liquibase formatted sql
-- changeset SAMQA:1754373928948 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_upload_staging_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_upload_staging_n4.sql:null:d0ac613f01463efe1d759bdeff9c2939bf42d735:create

create index samqa.ach_upload_staging_n4 on
    samqa.ach_upload_staging (
        er_acc_id,
        er_acc_num
    );

