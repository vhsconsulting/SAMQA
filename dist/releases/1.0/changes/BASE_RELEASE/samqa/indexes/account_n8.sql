-- liquibase formatted sql
-- changeset SAMQA:1754373928800 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_n8.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_n8.sql:null:6beb53d8298440e96b8522cdbd1714a485e8d14d:create

create index samqa.account_n8 on
    samqa.account (
        pers_id,
        account_status
    );

