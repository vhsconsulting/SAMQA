-- liquibase formatted sql
-- changeset SAMQA:1754373929832 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_assignments_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_assignments_idx1.sql:null:04b1964765c0aae516ac4d54c923c2b280b4e734:create

create index samqa.broker_assignments_idx1 on
    samqa.broker_assignments (
        entrp_id,
        pers_id,
        effective_date
    );

