-- liquibase formatted sql
-- changeset SAMQA:1754373939235 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.checkbook_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.checkbook_gp.sql:null:7a6308250f2294cd762dc031fe9cf449265463c5:create

grant delete on samqa.checkbook_gp to rl_sam_rw;

grant insert on samqa.checkbook_gp to rl_sam_rw;

grant select on samqa.checkbook_gp to rl_sam1_ro;

grant select on samqa.checkbook_gp to rl_sam_rw;

grant select on samqa.checkbook_gp to rl_sam_ro;

grant update on samqa.checkbook_gp to rl_sam_rw;

