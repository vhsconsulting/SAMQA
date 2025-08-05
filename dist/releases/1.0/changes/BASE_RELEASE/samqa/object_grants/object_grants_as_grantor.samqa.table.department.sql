-- liquibase formatted sql
-- changeset SAMQA:1754373939756 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.department.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.department.sql:null:b73fb521373a847bca8c154ae5bb52fb28207e2d:create

grant delete on samqa.department to rl_sam_rw;

grant insert on samqa.department to rl_sam_rw;

grant select on samqa.department to rl_sam1_ro;

grant select on samqa.department to rl_sam_rw;

grant select on samqa.department to rl_sam_ro;

grant update on samqa.department to rl_sam_rw;

