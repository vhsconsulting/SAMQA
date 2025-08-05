-- liquibase formatted sql
-- changeset SAMQA:1754373932466 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_fsa_hra_plan_staging_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_fsa_hra_plan_staging_n4.sql:null:0459901d47ac51616dd9e98bbe3f368d252ada74:create

create index samqa.online_fsa_hra_plan_staging_n4 on
    samqa.online_fsa_hra_plan_staging (
        org_ben_plan_id
    );

