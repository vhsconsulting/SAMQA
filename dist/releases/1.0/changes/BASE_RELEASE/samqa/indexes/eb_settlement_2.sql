-- liquibase formatted sql
-- changeset SAMQA:1754373930853 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eb_settlement_2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eb_settlement_2.sql:null:04225c8faeba1a5fea5c2eeecf2e90e8f367ed3c:create

create index samqa.eb_settlement_2 on
    samqa.eb_settlement (
        claim_id
    );

