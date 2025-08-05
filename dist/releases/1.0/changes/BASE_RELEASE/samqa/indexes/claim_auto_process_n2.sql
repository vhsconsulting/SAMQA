-- liquibase formatted sql
-- changeset SAMQA:1754373930099 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_auto_process_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_auto_process_n2.sql:null:63216a8386723f00e904a6f9feeca30b0bb771c2:create

create index samqa.claim_auto_process_n2 on
    samqa.claim_auto_process (
        entrp_id
    );

