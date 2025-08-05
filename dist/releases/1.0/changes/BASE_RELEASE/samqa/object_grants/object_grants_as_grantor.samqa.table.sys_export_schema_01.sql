-- liquibase formatted sql
-- changeset SAMQA:1754373942235 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sys_export_schema_01.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sys_export_schema_01.sql:null:1ab286355a75c8333a03cd824e30667ee7f5509b:create

grant delete on samqa.sys_export_schema_01 to rl_sam_rw;

grant insert on samqa.sys_export_schema_01 to rl_sam_rw;

grant select on samqa.sys_export_schema_01 to rl_sam_rw;

grant select on samqa.sys_export_schema_01 to rl_sam1_ro;

grant select on samqa.sys_export_schema_01 to rl_sam_ro;

grant update on samqa.sys_export_schema_01 to rl_sam_rw;

