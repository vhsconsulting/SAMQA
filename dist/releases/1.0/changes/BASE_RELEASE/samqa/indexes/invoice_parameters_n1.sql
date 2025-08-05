-- liquibase formatted sql
-- changeset SAMQA:1754373931835 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invoice_parameters_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invoice_parameters_n1.sql:null:3f8a0fde2be10ddc5b0d737a78c2de3d3f1348b3:create

create index samqa.invoice_parameters_n1 on
    samqa.invoice_parameters (
        entity_id,
        entity_type
    );

