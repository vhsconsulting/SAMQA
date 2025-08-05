-- liquibase formatted sql
-- changeset SAMQA:1754373933482 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\tax_forms_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/tax_forms_n1.sql:null:7672c1307dc640e4489022784a0a843f2e2763a9:create

create index samqa.tax_forms_n1 on
    samqa.tax_forms (
        acc_id
    );

