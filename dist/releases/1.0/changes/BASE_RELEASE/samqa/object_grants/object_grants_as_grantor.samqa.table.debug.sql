-- liquibase formatted sql
-- changeset SAMQA:1754373939694 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debug.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debug.sql:null:a2c0423c45925481a8786c724a61f34702239ae5:create

grant delete on samqa.debug to rl_sam_rw;

grant insert on samqa.debug to rl_sam_rw;

grant select on samqa.debug to rl_sam1_ro;

grant select on samqa.debug to rl_sam_rw;

grant select on samqa.debug to rl_sam_ro;

grant update on samqa.debug to rl_sam_rw;

