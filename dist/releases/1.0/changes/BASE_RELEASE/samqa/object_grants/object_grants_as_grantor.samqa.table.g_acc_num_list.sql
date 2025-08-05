-- liquibase formatted sql
-- changeset SAMQA:1754373940568 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.g_acc_num_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.g_acc_num_list.sql:null:2f752714de20c972cc38abe649b22e36fc025526:create

grant delete on samqa.g_acc_num_list to rl_sam_rw;

grant insert on samqa.g_acc_num_list to rl_sam_rw;

grant select on samqa.g_acc_num_list to rl_sam1_ro;

grant select on samqa.g_acc_num_list to rl_sam_ro;

grant select on samqa.g_acc_num_list to rl_sam_rw;

grant update on samqa.g_acc_num_list to rl_sam_rw;

