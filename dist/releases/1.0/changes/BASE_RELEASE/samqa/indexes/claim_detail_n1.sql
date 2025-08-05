-- liquibase formatted sql
-- changeset SAMQA:1754373930183 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_detail_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_detail_n1.sql:null:53d899def0f68e56139003cff4d417db202b628f:create

create index samqa.claim_detail_n1 on
    samqa.claim_detail (
        claim_id
    );

