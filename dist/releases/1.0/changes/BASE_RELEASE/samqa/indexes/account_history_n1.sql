-- liquibase formatted sql
-- changeset SAMQA:1754373928748 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_history_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_history_n1.sql:null:fc935cdba87749cae27a9cd62cfe86f5621d8b88:create

create index samqa.account_history_n1 on
    samqa.account_history (
        acc_id
    );

