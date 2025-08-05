-- liquibase formatted sql
-- changeset SAMQA:1754373931779 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\investment_fk1_i.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/investment_fk1_i.sql:null:b6ca0513f7e6ad49d619705962c4dbc10725674c:create

create index samqa.investment_fk1_i on
    samqa.investment (
        acc_id
    );

