-- liquibase formatted sql
-- changeset SAMQA:1754373930487 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n9.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n9.sql:null:76365ea6c2f75d99a855879fd686435bd163f30b:create

create index samqa.claimn_n9 on
    samqa.claimn (
        claim_id,
        claim_status
    );

