-- liquibase formatted sql
-- changeset SAMQA:1754373938456 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ach_return_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ach_return_codes.sql:null:29618fc3248f55545e205b2edc15935c9d4a8b9c:create

grant delete on samqa.ach_return_codes to rl_sam_rw;

grant insert on samqa.ach_return_codes to rl_sam_rw;

grant select on samqa.ach_return_codes to rl_sam1_ro;

grant select on samqa.ach_return_codes to rl_sam_ro;

grant select on samqa.ach_return_codes to rl_sam_rw;

grant update on samqa.ach_return_codes to rl_sam_rw;

