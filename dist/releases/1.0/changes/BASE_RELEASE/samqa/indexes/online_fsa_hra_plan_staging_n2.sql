-- liquibase formatted sql
-- changeset SAMQA:1754373932451 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_fsa_hra_plan_staging_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_fsa_hra_plan_staging_n2.sql:null:9aad03a85fc80361f95de0df42dbca3e6164c6a5:create

create index samqa.online_fsa_hra_plan_staging_n2 on
    samqa.online_fsa_hra_plan_staging (
        ben_plan_id
    );

