-- liquibase formatted sql
-- changeset SAMQA:1754373932076 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_cards_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_cards_n1.sql:null:9b12a55832b609d105f8681d47bf2d6ac14c38ac:create

create index samqa.metavante_cards_n1 on
    samqa.metavante_cards (
        acc_num
    );

