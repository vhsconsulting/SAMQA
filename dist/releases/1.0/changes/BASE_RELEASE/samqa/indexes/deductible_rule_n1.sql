-- liquibase formatted sql
-- changeset SAMQA:1754373930750 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deductible_rule_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deductible_rule_n1.sql:null:cdb95b40ce64adff38739afb0c2c79fd377854ce:create

create index samqa.deductible_rule_n1 on
    samqa.deductible_rule (
        ben_plan_id
    );

