-- liquibase formatted sql
-- changeset SAMQA:1754373932093 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_cards_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_cards_n3.sql:null:52ea2ab0dbb62417134b61926fd379fcf10434cf:create

create index samqa.metavante_cards_n3 on
    samqa.metavante_cards (
        dependant_id
    );

