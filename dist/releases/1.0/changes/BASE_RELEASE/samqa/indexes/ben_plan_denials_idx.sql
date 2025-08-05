-- liquibase formatted sql
-- changeset SAMQA:1754373929446 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_denials_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_denials_idx.sql:null:3e45d0e14f4be1ca8d15165d75c4f62556d42012:create

create index samqa.ben_plan_denials_idx on
    samqa.ben_plan_denials (
        ben_plan_id
    );

