-- liquibase formatted sql
-- changeset SAMQA:1754373932500 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_hfsa_enroll_stage_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_hfsa_enroll_stage_n2.sql:null:2440e7a4b112c51457fa739ab51c2162d979d059:create

create index samqa.online_hfsa_enroll_stage_n2 on
    samqa.online_hfsa_enroll_stage (
        plan_type
    );

