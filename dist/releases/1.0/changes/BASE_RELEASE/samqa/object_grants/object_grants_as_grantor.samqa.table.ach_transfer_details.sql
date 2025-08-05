-- liquibase formatted sql
-- changeset SAMQA:1754373938474 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ach_transfer_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ach_transfer_details.sql:null:7f99af3caa0389762ebe6a7a9b01545908f07809:create

grant delete on samqa.ach_transfer_details to rl_sam_rw;

grant insert on samqa.ach_transfer_details to rl_sam_rw;

grant select on samqa.ach_transfer_details to rl_sam1_ro;

grant select on samqa.ach_transfer_details to rl_sam_rw;

grant select on samqa.ach_transfer_details to rl_sam_ro;

grant update on samqa.ach_transfer_details to rl_sam_rw;

