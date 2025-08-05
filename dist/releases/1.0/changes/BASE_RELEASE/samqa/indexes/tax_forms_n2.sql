-- liquibase formatted sql
-- changeset SAMQA:1754373933499 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\tax_forms_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/tax_forms_n2.sql:null:0c6befc4b9605397bd79a20aaecef93d878e35f1:create

create index samqa.tax_forms_n2 on
    samqa.tax_forms (
        pers_id
    );

