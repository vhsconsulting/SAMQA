-- liquibase formatted sql
-- changeset SAMQA:1754373939044 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_account_hsa_rnw_rev_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_account_hsa_rnw_rev_mv.sql:null:4fe994dd8c48a6d8984cfd9218ab447df0852627:create

grant select on samqa.broker_account_hsa_rnw_rev_mv to rl_sam_rw;

grant select on samqa.broker_account_hsa_rnw_rev_mv to rl_sam_ro;

grant read on samqa.broker_account_hsa_rnw_rev_mv to rl_sam_rw;

grant read on samqa.broker_account_hsa_rnw_rev_mv to rl_sam_ro;

