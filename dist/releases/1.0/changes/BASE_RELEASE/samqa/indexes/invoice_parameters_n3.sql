-- liquibase formatted sql
-- changeset SAMQA:1754373931856 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invoice_parameters_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invoice_parameters_n3.sql:null:b47728db6abc305106481dddc81d573691965232:create

create index samqa.invoice_parameters_n3 on
    samqa.invoice_parameters (
        invoice_type
    );

