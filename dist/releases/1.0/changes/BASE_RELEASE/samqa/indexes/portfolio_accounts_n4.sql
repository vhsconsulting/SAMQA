-- liquibase formatted sql
-- changeset SAMQA:1754373933049 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\portfolio_accounts_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/portfolio_accounts_n4.sql:null:6bebcfaa252801a5797c79bdedb8584a5cee2b4f:create

create index samqa.portfolio_accounts_n4 on
    samqa.portfolio_accounts (
        user_id
    );

