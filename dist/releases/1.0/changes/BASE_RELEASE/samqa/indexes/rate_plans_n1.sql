-- liquibase formatted sql
-- changeset SAMQA:1754373933109 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_plans_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_plans_n1.sql:null:cd36ebfee244815e4fcc50f967f57a3b5f06d27e:create

create index samqa.rate_plans_n1 on
    samqa.rate_plans (
        entity_type,
        entity_id
    );

