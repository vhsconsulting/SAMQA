-- liquibase formatted sql
-- changeset SAMQA:1754373933137 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\rate_structure_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/rate_structure_n4.sql:null:37d178a04dcfedd15ed40b203ed0315e049e29a4:create

create index samqa.rate_structure_n4 on
    samqa.rate_structure (
        plan_type
    );

