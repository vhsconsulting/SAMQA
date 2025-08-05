-- liquibase formatted sql
-- changeset SAMQA:1754373945395 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.user_bank_acct_broker_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.user_bank_acct_broker_v.sql:null:e56f5443638094907275d939ebca42ada4487cc6:create

grant select on samqa.user_bank_acct_broker_v to rl_sam_ro;

grant select on samqa.user_bank_acct_broker_v to rl_sam_rw;

grant select on samqa.user_bank_acct_broker_v to rl_sam1_ro;

