-- liquibase formatted sql
-- changeset SAMQA:1754373930121 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_auto_process_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_auto_process_n4.sql:null:6a3474b3709e21ebeb5c81c701c9f5d4c4ef552e:create

create index samqa.claim_auto_process_n4 on
    samqa.claim_auto_process (
        invoice_status
    );

