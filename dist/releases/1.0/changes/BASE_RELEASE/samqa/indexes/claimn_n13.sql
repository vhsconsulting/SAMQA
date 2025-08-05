-- liquibase formatted sql
-- changeset SAMQA:1754373930422 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n13.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n13.sql:null:0a2631b5f5777492b04de3df892d89d61d4ad192:create

create index samqa.claimn_n13 on
    samqa.claimn (
        claim_source
    );

