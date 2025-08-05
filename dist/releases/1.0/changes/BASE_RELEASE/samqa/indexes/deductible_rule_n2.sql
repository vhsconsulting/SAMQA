-- liquibase formatted sql
-- changeset SAMQA:1754373930757 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deductible_rule_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deductible_rule_n2.sql:null:e5bee88b7abcf010a8ed0e90e20f45f502e2e59d:create

create index samqa.deductible_rule_n2 on
    samqa.deductible_rule (
        entrp_id
    );

