-- liquibase formatted sql
-- changeset SAMQA:1754373942443 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.userip.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.userip.sql:null:54e859afbd35cba27d113bf2d6cbb968706e6109:create

grant delete on samqa.userip to rl_sam_rw;

grant insert on samqa.userip to rl_sam_rw;

grant select on samqa.userip to rl_sam1_ro;

grant select on samqa.userip to rl_sam_rw;

grant select on samqa.userip to rl_sam_ro;

grant update on samqa.userip to rl_sam_rw;

