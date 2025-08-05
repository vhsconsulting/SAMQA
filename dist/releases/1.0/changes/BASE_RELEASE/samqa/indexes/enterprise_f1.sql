-- liquibase formatted sql
-- changeset SAMQA:1754373931326 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enterprise_f1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enterprise_f1.sql:null:a56aa659d18c587a1461e2411452b228f9283911:create

create index samqa.enterprise_f1 on
    samqa.enterprise ( replace(entrp_code, '-') );

