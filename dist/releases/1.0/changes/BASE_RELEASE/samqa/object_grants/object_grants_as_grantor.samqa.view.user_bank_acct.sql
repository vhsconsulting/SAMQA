-- liquibase formatted sql
-- changeset SAMQA:1754373945394 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.user_bank_acct.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.user_bank_acct.sql:null:a05308a8dbe1e5bc66fd701c8ce8c032daf0e6e5:create

grant delete on samqa.user_bank_acct to shavee;

grant insert on samqa.user_bank_acct to shavee;

grant select on samqa.user_bank_acct to rl_sam1_ro;

grant select on samqa.user_bank_acct to rl_sam_ro;

grant select on samqa.user_bank_acct to rl_sam_rw;

grant select on samqa.user_bank_acct to shavee;

grant update on samqa.user_bank_acct to shavee;

grant references on samqa.user_bank_acct to shavee;

grant read on samqa.user_bank_acct to shavee;

grant on commit refresh on samqa.user_bank_acct to shavee;

grant query rewrite on samqa.user_bank_acct to shavee;

grant debug on samqa.user_bank_acct to shavee;

grant flashback on samqa.user_bank_acct to shavee;

grant merge view on samqa.user_bank_acct to shavee;

