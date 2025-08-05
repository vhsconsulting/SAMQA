-- liquibase formatted sql
-- changeset SAMQA:1754373931413 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eob_header_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eob_header_n4.sql:null:ede8c132b67c0db43b56729340f21e759e248fe2:create

create index samqa.eob_header_n4 on
    samqa.eob_header (
        claim_number
    );

