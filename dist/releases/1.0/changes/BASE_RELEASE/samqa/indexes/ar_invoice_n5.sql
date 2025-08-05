-- liquibase formatted sql
-- changeset SAMQA:1754373929151 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n5.sql:null:b9acd56f6fd6f7c0f2aa1a86520d37653674f6ae:create

create index samqa.ar_invoice_n5 on
    samqa.ar_invoice (
        entity_id,
        entity_type
    );

