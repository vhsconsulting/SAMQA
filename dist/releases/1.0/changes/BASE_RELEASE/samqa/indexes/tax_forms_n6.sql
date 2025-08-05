-- liquibase formatted sql
-- changeset SAMQA:1754373933530 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\tax_forms_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/tax_forms_n6.sql:null:c25b9604be6b1610f80c815fbd67fdd73eb4231b:create

create index samqa.tax_forms_n6 on
    samqa.tax_forms (
        end_date
    );

