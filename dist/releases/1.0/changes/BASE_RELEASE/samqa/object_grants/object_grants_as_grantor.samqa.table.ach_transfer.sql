-- liquibase formatted sql
-- changeset SAMQA:1754373938466 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ach_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ach_transfer.sql:null:fef51ce39945d1b9a5b95c2fb463cbce09db1933:create

grant delete on samqa.ach_transfer to rl_sam_rw;

grant insert on samqa.ach_transfer to rl_sam_rw;

grant insert on samqa.ach_transfer to amrish_admin;

grant select on samqa.ach_transfer to newcobra;

grant select on samqa.ach_transfer to rl_sam_rw;

grant select on samqa.ach_transfer to rl_sam_ro;

grant select on samqa.ach_transfer to rl_sam1_ro;

grant select on samqa.ach_transfer to amrish_admin;

grant update on samqa.ach_transfer to amrish_admin;

grant update on samqa.ach_transfer to rl_sam_rw;

