-- liquibase formatted sql
-- changeset SAMQA:1754373931396 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eob_header_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eob_header_n2.sql:null:f267fee292d32c11920b7d6b0ddc830a0bb0e0cc:create

create index samqa.eob_header_n2 on
    samqa.eob_header (
        claim_id
    );

