-- liquibase formatted sql
-- changeset SAMQA:1754373932436 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enrollment_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enrollment_n4.sql:null:0dbafff224ecdab00107c3a15cf76654cc55fafe:create

create index samqa.online_enrollment_n4 on
    samqa.online_enrollment (
        batch_number,
        entrp_id,
        ssn
    );

