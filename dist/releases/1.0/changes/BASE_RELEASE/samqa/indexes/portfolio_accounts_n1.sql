-- liquibase formatted sql
-- changeset SAMQA:1754373933013 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\portfolio_accounts_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/portfolio_accounts_n1.sql:null:bf237edd67f8139f5ea3a5890ebd70d169d72f5e:create

create index samqa.portfolio_accounts_n1 on
    samqa.portfolio_accounts (
        acc_num
    );

