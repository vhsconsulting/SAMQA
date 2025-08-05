-- liquibase formatted sql
-- changeset SAMQA:1754373930390 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_idx2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_idx2.sql:null:3450a69fd98433d908bd69ed2e5ad03e7641d270:create

create index samqa.claimn_idx2 on
    samqa.claimn (
        claim_code
    );

