-- liquibase formatted sql
-- changeset SAMQA:1754373933514 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\tax_forms_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/tax_forms_n4.sql:null:fa71824d78fb21341615204720f8da5e8e1f44b1:create

create index samqa.tax_forms_n4 on
    samqa.tax_forms (
        batch_number
    );

