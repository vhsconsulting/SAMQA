-- liquibase formatted sql
-- changeset SAMQA:1754373939059 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_account_nohsa_rnw_rev_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_account_nohsa_rnw_rev_mv.sql:null:99dfcf148d0dad902b5a64786488787e2adb14e0:create

grant select on samqa.broker_account_nohsa_rnw_rev_mv to rl_sam_rw;

grant select on samqa.broker_account_nohsa_rnw_rev_mv to rl_sam_ro;

grant read on samqa.broker_account_nohsa_rnw_rev_mv to rl_sam_rw;

grant read on samqa.broker_account_nohsa_rnw_rev_mv to rl_sam_ro;

