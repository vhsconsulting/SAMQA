-- liquibase formatted sql
-- changeset SAMQA:1754373932118 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_cards_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_cards_u1.sql:null:dbf941818d17cbe13049a8213c4cac9c67663177:create

create unique index samqa.metavante_cards_u1 on
    samqa.metavante_cards (
        metavante_card_id
    );

