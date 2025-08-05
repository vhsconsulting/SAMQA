-- liquibase formatted sql
-- changeset SAMQA:1754373940398 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.external_files.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.external_files.sql:null:9004029fe3735db067f3de8dbff754df3db89e51:create

grant delete on samqa.external_files to rl_sam_rw;

grant insert on samqa.external_files to rl_sam_rw;

grant select on samqa.external_files to rl_sam1_ro;

grant select on samqa.external_files to rl_sam_rw;

grant select on samqa.external_files to rl_sam_ro;

grant update on samqa.external_files to rl_sam_rw;

