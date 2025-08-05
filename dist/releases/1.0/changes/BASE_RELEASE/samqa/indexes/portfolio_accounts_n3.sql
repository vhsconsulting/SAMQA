-- liquibase formatted sql
-- changeset SAMQA:1754373933035 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\portfolio_accounts_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/portfolio_accounts_n3.sql:null:67f4d7d687e5fb58e4bdfbfa703af66e9f43adf5:create

create index samqa.portfolio_accounts_n3 on
    samqa.portfolio_accounts (
        entity_type,
        entity_id
    );

