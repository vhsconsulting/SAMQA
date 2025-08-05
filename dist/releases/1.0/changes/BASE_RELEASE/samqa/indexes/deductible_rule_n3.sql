-- liquibase formatted sql
-- changeset SAMQA:1754373930766 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deductible_rule_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deductible_rule_n3.sql:null:a13ecd00f1284c97558628b39ff1619d2f0e6c2c:create

create index samqa.deductible_rule_n3 on
    samqa.deductible_rule (
        acc_id
    );

