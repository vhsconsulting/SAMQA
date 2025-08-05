-- liquibase formatted sql
-- changeset SAMQA:1754373932110 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_cards_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_cards_n5.sql:null:eae9f5b00cf90f86c67c70bfa9cf86f61fbf05e8:create

create index samqa.metavante_cards_n5 on
    samqa.metavante_cards ( to_date(
        issue_date, 'YYYYMMDD') );

