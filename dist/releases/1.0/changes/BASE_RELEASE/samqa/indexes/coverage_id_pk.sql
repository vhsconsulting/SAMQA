-- liquibase formatted sql
-- changeset SAMQA:1754373930669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\coverage_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/coverage_id_pk.sql:null:069794d6db7d62fffd306e03b3f53589352d0a98:create

create unique index samqa.coverage_id_pk on
    samqa.ben_plan_coverages_staging (
        coverage_id
    );

