-- liquibase formatted sql
-- changeset SAMQA:1754373931883 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\list_bill_upload_staging_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/list_bill_upload_staging_n1.sql:null:6d2a10cd3b236778b762b710c80f9a94f03b9ff1:create

create index samqa.list_bill_upload_staging_n1 on
    samqa.list_bill_upload_staging (
        batch_number
    );

