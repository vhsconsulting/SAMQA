-- liquibase formatted sql
-- changeset SAMQA:1754373929819 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_assignment_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_assignment_n2.sql:null:ae11ae2f4dfa56ffa85892a82d15adc7b169a204:create

create index samqa.broker_assignment_n2 on
    samqa.broker_assignments (
        broker_id,
        pers_id
    );

