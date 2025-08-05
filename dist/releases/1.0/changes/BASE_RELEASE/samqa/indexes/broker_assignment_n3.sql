-- liquibase formatted sql
-- changeset SAMQA:1754373929819 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_assignment_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_assignment_n3.sql:null:57733936480b95bd462cee0cf9d4701004eac60a:create

create index samqa.broker_assignment_n3 on
    samqa.broker_assignments (
        broker_id,
        entrp_id
    );

