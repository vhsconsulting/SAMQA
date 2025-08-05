-- liquibase formatted sql
-- changeset SAMQA:1754373930881 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eb_settlement_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eb_settlement_pk.sql:null:62c1e33312105020d4fba6d62c5acb7978089fcb:create

create index samqa.eb_settlement_pk on
    samqa.eb_settlement (
        settle_num
    );

