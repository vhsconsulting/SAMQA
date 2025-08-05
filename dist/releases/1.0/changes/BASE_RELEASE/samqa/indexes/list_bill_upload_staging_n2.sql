-- liquibase formatted sql
-- changeset SAMQA:1754373931891 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\list_bill_upload_staging_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/list_bill_upload_staging_n2.sql:null:cdb22dd75ce9e5ad2592c3c77188b7ae5e004ba6:create

create index samqa.list_bill_upload_staging_n2 on
    samqa.list_bill_upload_staging (
        list_bill_num
    );

