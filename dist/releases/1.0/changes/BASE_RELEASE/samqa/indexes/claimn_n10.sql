-- liquibase formatted sql
-- changeset SAMQA:1754373930398 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n10.sql:null:9513d0b761244e45bf82796106fcd7de6c817e07:create

create index samqa.claimn_n10 on
    samqa.claimn (
        source_claim_id
    );

