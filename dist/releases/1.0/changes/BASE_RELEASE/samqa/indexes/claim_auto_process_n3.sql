-- liquibase formatted sql
-- changeset SAMQA:1754373930107 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_auto_process_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_auto_process_n3.sql:null:eb595897ee08ad8a470611450b32a3eb8130a289:create

create index samqa.claim_auto_process_n3 on
    samqa.claim_auto_process (
        process_status
    );

