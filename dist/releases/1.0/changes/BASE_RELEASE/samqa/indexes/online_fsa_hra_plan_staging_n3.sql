-- liquibase formatted sql
-- changeset SAMQA:1754373932459 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_fsa_hra_plan_staging_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_fsa_hra_plan_staging_n3.sql:null:f59c914482933beee55adaea6be447936a86a587:create

create index samqa.online_fsa_hra_plan_staging_n3 on
    samqa.online_fsa_hra_plan_staging (
        batch_number
    );

