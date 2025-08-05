-- liquibase formatted sql
-- changeset SAMQA:1754373933130 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plans_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plans_n3.sql:null:760228351a9af8b813291b425af6623ea41b5fd5:create

create index samqa.rate_plans_n3 on
    samqa.rate_plans (
        entity_id
    );

