-- liquibase formatted sql
-- changeset SAMQA:1754373940769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.htmldb_plan_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.htmldb_plan_table.sql:null:9c35a30cf01b06cf9779387321ed009c0d95cd89:create

grant delete on samqa.htmldb_plan_table to rl_sam_rw;

grant insert on samqa.htmldb_plan_table to rl_sam_rw;

grant select on samqa.htmldb_plan_table to rl_sam1_ro;

grant select on samqa.htmldb_plan_table to rl_sam_rw;

grant select on samqa.htmldb_plan_table to rl_sam_ro;

grant update on samqa.htmldb_plan_table to rl_sam_rw;

