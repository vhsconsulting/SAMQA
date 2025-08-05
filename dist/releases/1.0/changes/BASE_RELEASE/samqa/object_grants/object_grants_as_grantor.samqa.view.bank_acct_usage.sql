-- liquibase formatted sql
-- changeset SAMQA:1754373942943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.bank_acct_usage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.bank_acct_usage.sql:null:879ea45cc864313f58146bbb69269816c57af951:create

grant select on samqa.bank_acct_usage to rl_sam1_ro;

grant select on samqa.bank_acct_usage to rl_sam_rw;

grant select on samqa.bank_acct_usage to rl_sam_ro;

grant select on samqa.bank_acct_usage to sgali;

