-- liquibase formatted sql
-- changeset SAMQA:1754373928927 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_upload_staging_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_upload_staging_n1.sql:null:693e3454a9ec47b44bd412eb0dc7a53d270a4d3e:create

create index samqa.ach_upload_staging_n1 on
    samqa.ach_upload_staging (
        batch_number
    );

