-- liquibase formatted sql
-- changeset SAMQA:1754373942245 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sys_export_schema_02.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sys_export_schema_02.sql:null:95e388d434c32dcaffb43c3b084d1dbda7b41c76:create

grant delete on samqa.sys_export_schema_02 to rl_sam_rw;

grant insert on samqa.sys_export_schema_02 to rl_sam_rw;

grant select on samqa.sys_export_schema_02 to rl_sam_rw;

grant select on samqa.sys_export_schema_02 to rl_sam1_ro;

grant select on samqa.sys_export_schema_02 to rl_sam_ro;

grant update on samqa.sys_export_schema_02 to rl_sam_rw;

