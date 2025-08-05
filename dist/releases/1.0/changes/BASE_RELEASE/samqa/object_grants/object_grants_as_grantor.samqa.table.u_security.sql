-- liquibase formatted sql
-- changeset SAMQA:1754373942369 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.u_security.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.u_security.sql:null:ef282f41641efe10eb6e8cb5308994a4a3126af5:create

grant delete on samqa.u_security to rl_sam_rw;

grant insert on samqa.u_security to rl_sam_rw;

grant select on samqa.u_security to rl_sam1_ro;

grant select on samqa.u_security to rl_sam_rw;

grant select on samqa.u_security to rl_sam_ro;

grant update on samqa.u_security to rl_sam_rw;

