-- liquibase formatted sql
-- changeset SAMQA:1754373941986 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.salesrep.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.salesrep.sql:null:6b7f329c1c3bc9427a0f6aef49cd7ce31d85f52f:create

grant delete on samqa.salesrep to rl_sam_rw;

grant insert on samqa.salesrep to rl_sam_rw;

grant select on samqa.salesrep to rl_sam1_ro;

grant select on samqa.salesrep to rl_sam_rw;

grant select on samqa.salesrep to rl_sam_ro;

grant select on samqa.salesrep to reportdb_ro;

grant update on samqa.salesrep to rl_sam_rw;

