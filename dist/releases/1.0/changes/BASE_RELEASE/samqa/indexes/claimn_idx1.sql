-- liquibase formatted sql
-- changeset SAMQA:1754373930380 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_idx1.sql:null:3a020f5c5a612b75f8eb5d9d1c3d752b2654ec42:create

create index samqa.claimn_idx1 on
    samqa.claimn (
        claim_id,
        pers_id
    );

