-- liquibase formatted sql
-- changeset SAMQA:1754373938443 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.accres.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.accres.sql:null:88989b918ab71cebb790a08531d870b20c3e78d9:create

grant delete on samqa.accres to rl_sam_rw;

grant insert on samqa.accres to rl_sam_rw;

grant select on samqa.accres to rl_sam1_ro;

grant select on samqa.accres to rl_sam_rw;

grant select on samqa.accres to rl_sam_ro;

grant update on samqa.accres to rl_sam_rw;

