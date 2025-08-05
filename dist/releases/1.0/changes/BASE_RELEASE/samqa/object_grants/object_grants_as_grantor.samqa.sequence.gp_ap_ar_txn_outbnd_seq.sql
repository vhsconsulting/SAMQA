-- liquibase formatted sql
-- changeset SAMQA:1754373937833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.gp_ap_ar_txn_outbnd_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.gp_ap_ar_txn_outbnd_seq.sql:null:472aa267c1280ca4be2b3f1eec01c7f2ca3cdd3a:create

grant select on samqa.gp_ap_ar_txn_outbnd_seq to rl_sam_rw;

