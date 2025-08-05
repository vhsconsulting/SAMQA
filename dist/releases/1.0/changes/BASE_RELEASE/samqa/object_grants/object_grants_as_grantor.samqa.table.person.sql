-- liquibase formatted sql
-- changeset SAMQA:1754373941654 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.person.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.person.sql:null:9735f7d562c8e91e1f0919f2379fdb6274228ab8:create

grant delete on samqa.person to rl_sam_rw;

grant insert on samqa.person to rl_sam_rw;

grant insert on samqa.person to cobra;

grant select on samqa.person to rl_sam1_ro;

grant select on samqa.person to public;

grant select on samqa.person to rl_sam_rw;

grant select on samqa.person to rl_sam_ro;

grant select on samqa.person to asis;

grant select on samqa.person to cobra;

grant select on samqa.person to reportdb_ro;

grant update on samqa.person to rl_sam_rw;

grant update on samqa.person to cobra;

