-- liquibase formatted sql
-- changeset SAMQA:1754373932492 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_hfsa_enroll_stage_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_hfsa_enroll_stage_n1.sql:null:20ea38e5a52a6ce066dd3155f2084752621034bf:create

create index samqa.online_hfsa_enroll_stage_n1 on
    samqa.online_hfsa_enroll_stage (
        ssn
    );

