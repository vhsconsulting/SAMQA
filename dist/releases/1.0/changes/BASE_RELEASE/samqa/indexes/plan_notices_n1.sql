-- liquibase formatted sql
-- changeset SAMQA:1754373932948 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\plan_notices_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/plan_notices_n1.sql:null:426e3dcc23fc7339c58cb3be502ccfdb7b04727e:create

create index samqa.plan_notices_n1 on
    samqa.plan_notices (
        entity_type,
        entity_id
    );

