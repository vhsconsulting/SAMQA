-- liquibase formatted sql
-- changeset SAMQA:1754373939029 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker.sql:null:35c9e6268dab3e84224e74a13f13767822584299:create

grant delete on samqa.broker to rl_sam_rw;

grant insert on samqa.broker to rl_sam_rw;

grant select on samqa.broker to rl_sam1_ro;

grant select on samqa.broker to rl_sam_rw;

grant select on samqa.broker to rl_sam_ro;

grant select on samqa.broker to reportdb_ro;

grant update on samqa.broker to rl_sam_rw;

