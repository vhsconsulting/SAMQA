-- liquibase formatted sql
-- changeset SAMQA:1754373933516 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\tax_forms_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/tax_forms_n5.sql:null:e691a04ef5cde7f952c351607b41dcdb60f3e823:create

create index samqa.tax_forms_n5 on
    samqa.tax_forms (
        start_date
    );

