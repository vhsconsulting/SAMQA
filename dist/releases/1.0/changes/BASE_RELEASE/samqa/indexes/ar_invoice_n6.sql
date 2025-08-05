-- liquibase formatted sql
-- changeset SAMQA:1754373929166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n6.sql:null:e00f4d991736f8665b8498978e2f681ddbc8b393:create

create index samqa.ar_invoice_n6 on
    samqa.ar_invoice (
        batch_number
    );

