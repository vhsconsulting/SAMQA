-- liquibase formatted sql
-- changeset SAMQA:1754373932987 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\plans_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/plans_idx1.sql:null:6f7c2140e778dd256481d4ae94c844daa5ddba85:create

create index samqa.plans_idx1 on
    samqa.plans (
        plan_code,
        entrp_id
    );

