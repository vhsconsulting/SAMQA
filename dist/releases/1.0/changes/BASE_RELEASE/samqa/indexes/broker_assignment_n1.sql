-- liquibase formatted sql
-- changeset SAMQA:1754373929813 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_assignment_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_assignment_n1.sql:null:e752e47694322a69ecffd79144ca06acf9bddab5:create

create index samqa.broker_assignment_n1 on
    samqa.broker_assignments (
        broker_id
    );

