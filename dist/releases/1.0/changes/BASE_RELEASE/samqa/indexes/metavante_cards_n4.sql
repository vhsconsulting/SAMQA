-- liquibase formatted sql
-- changeset SAMQA:1754373932102 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_cards_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_cards_n4.sql:null:ecfddd96e3bee4b659ce75b753db146faef1db10:create

create index samqa.metavante_cards_n4 on
    samqa.metavante_cards (
        acc_num,
        card_number,
        dependant_id
    );

