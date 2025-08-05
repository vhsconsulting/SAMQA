-- liquibase formatted sql
-- changeset SAMQA:1754373930258 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_idx1.sql:null:f55f561fc4683ade9034f5911796d261c8f87bf9:create

create index samqa.claim_idx1 on
    samqa.claim (
        claim_id,
        pers_id
    );

