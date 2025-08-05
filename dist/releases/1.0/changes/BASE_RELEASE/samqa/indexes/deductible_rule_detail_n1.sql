-- liquibase formatted sql
-- changeset SAMQA:1754373930742 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deductible_rule_detail_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deductible_rule_detail_n1.sql:null:6b687e8c0cbb0c82d795a58e8d0e28b95b039a03:create

create index samqa.deductible_rule_detail_n1 on
    samqa.deductible_rule_detail (
        entity
    );

