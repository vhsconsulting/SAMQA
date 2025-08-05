-- liquibase formatted sql
-- changeset SAMQA:1754373942392 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.user_division_mapping.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.user_division_mapping.sql:null:7acdc136fbd749a4282d527645a1ff5f37461f13:create

grant delete on samqa.user_division_mapping to rl_sam_rw;

grant insert on samqa.user_division_mapping to rl_sam_rw;

grant select on samqa.user_division_mapping to rl_sam1_ro;

grant select on samqa.user_division_mapping to rl_sam_rw;

grant select on samqa.user_division_mapping to rl_sam_ro;

grant update on samqa.user_division_mapping to rl_sam_rw;

