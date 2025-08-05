-- liquibase formatted sql
-- changeset SAMQA:1754373931787 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\investment_fk2_i.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/investment_fk2_i.sql:null:d5821a7fc5b497d2ae3af6c41608f7b83f42ba96:create

create index samqa.investment_fk2_i on
    samqa.investment (
        invest_id
    );

