-- liquibase formatted sql
-- changeset SAMQA:1753779552707 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_n4.sql:null:a67a155dcdd470775f778d2aa219868aa8dfc448:create

create index samqa.account_n4 on
    samqa.account (
        closed_reason
    );

