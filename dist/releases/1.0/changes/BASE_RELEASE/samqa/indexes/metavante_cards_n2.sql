-- liquibase formatted sql
-- changeset SAMQA:1754373932083 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_cards_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_cards_n2.sql:null:9ed5445398e363b7d1feac3cafed16650c313537:create

create index samqa.metavante_cards_n2 on
    samqa.metavante_cards (
        card_number
    );

