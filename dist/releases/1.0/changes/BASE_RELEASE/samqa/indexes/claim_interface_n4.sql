-- liquibase formatted sql
-- changeset SAMQA:1754373930291 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_interface_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_interface_n4.sql:null:b4c48a89d272dfa19e8cfb4f400d419466a4cfb0:create

create index samqa.claim_interface_n4 on
    samqa.claim_interface (
        claim_number
    );

