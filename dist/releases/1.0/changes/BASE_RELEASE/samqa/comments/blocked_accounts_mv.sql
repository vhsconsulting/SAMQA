-- liquibase formatted sql
-- changeset samqa:1754373926460 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\blocked_accounts_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/blocked_accounts_mv.sql:null:f9a4e5f7a94e1213954dba980f05df2ec0411763:create

comment on table samqa.blocked_accounts_mv is
    'snapshot table for snapshot SAM.BLOCKED_ACCOUNTS_MV';

