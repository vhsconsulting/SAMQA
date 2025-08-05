-- liquibase formatted sql
-- changeset SAMQA:1754373942817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ach_transfer_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ach_transfer_status.sql:null:b70272d80ed054632314f4a9e823bb55fe769d07:create

grant select on samqa.ach_transfer_status to rl_sam1_ro;

grant select on samqa.ach_transfer_status to rl_sam_rw;

grant select on samqa.ach_transfer_status to rl_sam_ro;

grant select on samqa.ach_transfer_status to sgali;

