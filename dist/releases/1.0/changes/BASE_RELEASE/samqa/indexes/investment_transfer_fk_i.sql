-- liquibase formatted sql
-- changeset SAMQA:1754373931803 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\investment_transfer_fk_i.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/investment_transfer_fk_i.sql:null:fb8da9fd4ea885d8185c6ebb2c5125a586afb580:create

create index samqa.investment_transfer_fk_i on
    samqa.invest_transfer (
        investment_id
    );

