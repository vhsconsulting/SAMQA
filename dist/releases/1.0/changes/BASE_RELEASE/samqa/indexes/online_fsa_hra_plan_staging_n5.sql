-- liquibase formatted sql
-- changeset SAMQA:1754373932475 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_fsa_hra_plan_staging_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_fsa_hra_plan_staging_n5.sql:null:d924beaab86991f9bb1ef72ee5c48a1f43328e04:create

create index samqa.online_fsa_hra_plan_staging_n5 on
    samqa.online_fsa_hra_plan_staging (
        plan_type
    );

