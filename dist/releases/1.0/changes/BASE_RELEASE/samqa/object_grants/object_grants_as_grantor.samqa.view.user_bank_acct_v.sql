-- liquibase formatted sql
-- changeset SAMQA:1754373945410 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.user_bank_acct_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.user_bank_acct_v.sql:null:3a5904e81d55ee6fb003943bf6f9edee65bc4817:create

grant select on samqa.user_bank_acct_v to rl_sam_rw;

grant select on samqa.user_bank_acct_v to rl_sam_ro;

grant select on samqa.user_bank_acct_v to sgali;

grant select on samqa.user_bank_acct_v to rl_sam1_ro;

