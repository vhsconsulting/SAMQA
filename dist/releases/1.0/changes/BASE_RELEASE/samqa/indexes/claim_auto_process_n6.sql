-- liquibase formatted sql
-- changeset SAMQA:1754373930126 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_auto_process_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_auto_process_n6.sql:null:efade52aada0496f874d170eef4a7dd516a0fba6:create

create index samqa.claim_auto_process_n6 on
    samqa.claim_auto_process (
        batch_number
    );

