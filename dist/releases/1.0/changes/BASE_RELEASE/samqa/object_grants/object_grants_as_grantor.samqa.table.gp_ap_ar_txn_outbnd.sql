-- liquibase formatted sql
-- changeset SAMQA:1754373940625 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_ap_ar_txn_outbnd.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_ap_ar_txn_outbnd.sql:null:d1ea415501721f5eddf37820258f1e5b939cd630:create

grant delete on samqa.gp_ap_ar_txn_outbnd to rl_sam_rw;

grant insert on samqa.gp_ap_ar_txn_outbnd to rl_sam_rw;

grant select on samqa.gp_ap_ar_txn_outbnd to rl_sam_ro;

grant select on samqa.gp_ap_ar_txn_outbnd to rl_sam1_ro;

grant select on samqa.gp_ap_ar_txn_outbnd to rl_sam_rw;

grant update on samqa.gp_ap_ar_txn_outbnd to rl_sam_rw;

