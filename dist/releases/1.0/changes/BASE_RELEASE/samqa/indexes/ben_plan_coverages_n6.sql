-- liquibase formatted sql
-- changeset SAMQA:1754373929438 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_coverages_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_coverages_n6.sql:null:a9c1df99c5aa91fceb772e2650fbfdd003690657:create

create index samqa.ben_plan_coverages_n6 on
    samqa.ben_plan_coverages (
        coverage_tier_name
    );

