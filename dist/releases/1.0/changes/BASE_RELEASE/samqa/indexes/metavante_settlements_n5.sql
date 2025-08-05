-- liquibase formatted sql
-- changeset SAMQA:1754373932252 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_settlements_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_settlements_n5.sql:null:1d61c2b469afcdd983d6f4b438c965ab48971f92:create

create index samqa.metavante_settlements_n5 on
    samqa.metavante_settlements (
        claim_id
    );

