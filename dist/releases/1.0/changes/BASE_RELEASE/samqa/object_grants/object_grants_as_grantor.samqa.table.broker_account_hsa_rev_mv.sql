-- liquibase formatted sql
-- changeset SAMQA:1754373939036 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_account_hsa_rev_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_account_hsa_rev_mv.sql:null:1b32f8a4c57f7a2c7e28db748071eb6baa0e262d:create

grant select on samqa.broker_account_hsa_rev_mv to rl_sam_rw;

grant select on samqa.broker_account_hsa_rev_mv to rl_sam_ro;

grant read on samqa.broker_account_hsa_rev_mv to rl_sam_rw;

grant read on samqa.broker_account_hsa_rev_mv to rl_sam_ro;

