-- liquibase formatted sql
-- changeset SAMQA:1754373939874 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employee.sql:null:0ab1d91ec4fac9a1d03f06edf16dd8d2e5ab6a5b:create

grant delete on samqa.employee to rl_sam_rw;

grant insert on samqa.employee to rl_sam_rw;

grant select on samqa.employee to rl_sam1_ro;

grant select on samqa.employee to rl_sam_rw;

grant select on samqa.employee to rl_sam_ro;

grant update on samqa.employee to rl_sam_rw;

