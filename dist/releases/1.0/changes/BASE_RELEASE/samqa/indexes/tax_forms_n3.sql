-- liquibase formatted sql
-- changeset SAMQA:1754373933499 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\tax_forms_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/tax_forms_n3.sql:null:ebf22e52c70cd2ba37e9fedd334f3571918728a9:create

create index samqa.tax_forms_n3 on
    samqa.tax_forms (
        acc_num
    );

