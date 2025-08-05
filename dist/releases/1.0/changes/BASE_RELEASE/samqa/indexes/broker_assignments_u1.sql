-- liquibase formatted sql
-- changeset SAMQA:1754373929848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_assignments_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_assignments_u1.sql:null:506847685ef37561e584514e0ab2e30f067deca8:create

create index samqa.broker_assignments_u1 on
    samqa.broker_assignments (
        broker_assignment_id
    );

