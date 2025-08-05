-- liquibase formatted sql
-- changeset SAMQA:1754373939052 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_account_nohsa_rev_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_account_nohsa_rev_mv.sql:null:d4960565d61c84d47e9ba1a9e6335dbc5e5d0d6f:create

grant select on samqa.broker_account_nohsa_rev_mv to rl_sam_rw;

grant select on samqa.broker_account_nohsa_rev_mv to rl_sam_ro;

grant read on samqa.broker_account_nohsa_rev_mv to rl_sam_rw;

grant read on samqa.broker_account_nohsa_rev_mv to rl_sam_ro;

