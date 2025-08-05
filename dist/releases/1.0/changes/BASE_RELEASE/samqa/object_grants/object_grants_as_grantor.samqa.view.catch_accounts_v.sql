-- liquibase formatted sql
-- changeset SAMQA:1754373943246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.catch_accounts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.catch_accounts_v.sql:null:d2f6dec2eed66e2141447eaf31b8f618dff4778d:create

grant select on samqa.catch_accounts_v to rl_sam1_ro;

grant select on samqa.catch_accounts_v to rl_sam_rw;

grant select on samqa.catch_accounts_v to rl_sam_ro;

grant select on samqa.catch_accounts_v to sgali;

