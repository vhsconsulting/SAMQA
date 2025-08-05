-- liquibase formatted sql
-- changeset SAMQA:1754373929758 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bill_format_staging_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bill_format_staging_n6.sql:null:57feef1097d8ea3e80d91a8c1b9d2cbbc10c5aa9:create

create index samqa.bill_format_staging_n6 on
    samqa.bill_format_staging (
        ssn
    );

