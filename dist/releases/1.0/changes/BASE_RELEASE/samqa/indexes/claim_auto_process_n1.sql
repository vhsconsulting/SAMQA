-- liquibase formatted sql
-- changeset SAMQA:1754373930082 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_auto_process_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_auto_process_n1.sql:null:7a86c600ff27efc80c92d2484710f94f60eea436:create

create index samqa.claim_auto_process_n1 on
    samqa.claim_auto_process (
        claim_id
    );

