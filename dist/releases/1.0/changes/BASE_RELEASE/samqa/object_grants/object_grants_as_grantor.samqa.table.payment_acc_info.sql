-- liquibase formatted sql
-- changeset SAMQA:1754373941614 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.payment_acc_info.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.payment_acc_info.sql:null:5f8b49294626ce7acbcddcdd319541ca669875b7:create

grant delete on samqa.payment_acc_info to rl_sam_rw;

grant insert on samqa.payment_acc_info to rl_sam_rw;

grant select on samqa.payment_acc_info to rl_sam1_ro;

grant select on samqa.payment_acc_info to rl_sam_rw;

grant select on samqa.payment_acc_info to rl_sam_ro;

grant update on samqa.payment_acc_info to rl_sam_rw;

