-- liquibase formatted sql
-- changeset SAMQA:1754373932376 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enroll_plans_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enroll_plans_idx.sql:null:331ecc1d5ea681edf5ee77bb739f1a333739960e:create

create index samqa.online_enroll_plans_idx on
    samqa.online_enroll_plans (
        enrollment_id
    );

