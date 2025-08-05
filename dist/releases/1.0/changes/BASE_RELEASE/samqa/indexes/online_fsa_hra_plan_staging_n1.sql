-- liquibase formatted sql
-- changeset SAMQA:1754373932443 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_fsa_hra_plan_staging_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_fsa_hra_plan_staging_n1.sql:null:ecf46a8cba36407b39ef6b69729a07637b10dc66:create

create index samqa.online_fsa_hra_plan_staging_n1 on
    samqa.online_fsa_hra_plan_staging (
        enrollment_id
    );

