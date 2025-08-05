-- liquibase formatted sql
-- changeset SAMQA:1754373929848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_assignments_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_assignments_n4.sql:null:9763bbf605026ed6406f93df4a97999870bdfac2:create

create index samqa.broker_assignments_n4 on
    samqa.broker_assignments (
        broker_id,
        pers_id,
        entrp_id
    );

