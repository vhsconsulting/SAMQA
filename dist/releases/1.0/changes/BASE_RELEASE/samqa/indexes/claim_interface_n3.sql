-- liquibase formatted sql
-- changeset SAMQA:1754373930283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_interface_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_interface_n3.sql:null:50432a5545d9721b589985a76637b2efa5eebf11:create

create index samqa.claim_interface_n3 on
    samqa.claim_interface (
        pers_id
    );

