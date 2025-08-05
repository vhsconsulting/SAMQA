-- liquibase formatted sql
-- changeset SAMQA:1754373931795 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\investment_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/investment_idx1.sql:null:4ed1a2ab06fc241fbd5d88d00c3779c6dba435e4:create

create index samqa.investment_idx1 on
    samqa.investment (
        acc_id,
        invest_id
    );

