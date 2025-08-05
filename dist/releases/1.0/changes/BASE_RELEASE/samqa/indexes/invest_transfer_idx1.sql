-- liquibase formatted sql
-- changeset SAMQA:1754373931770 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invest_transfer_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invest_transfer_idx1.sql:null:dcbfa406e5873db411bd720fe832883cbc3357e4:create

create index samqa.invest_transfer_idx1 on
    samqa.invest_transfer (
        investment_id,
        invest_code
    );

