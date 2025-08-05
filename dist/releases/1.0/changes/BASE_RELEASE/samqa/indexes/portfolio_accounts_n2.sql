-- liquibase formatted sql
-- changeset SAMQA:1754373933025 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\portfolio_accounts_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/portfolio_accounts_n2.sql:null:4a48ed41f7e0c8eb82542c44b660915ded278f7d:create

create index samqa.portfolio_accounts_n2 on
    samqa.portfolio_accounts (
        tax_id
    );

