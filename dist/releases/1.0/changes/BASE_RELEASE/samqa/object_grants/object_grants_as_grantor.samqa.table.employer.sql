-- liquibase formatted sql
-- changeset SAMQA:1754373939882 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer.sql:null:5c70b6b27fa64d0c961a46aac58159d4da08f658:create

grant delete on samqa.employer to rl_sam_rw;

grant insert on samqa.employer to rl_sam_rw;

grant select on samqa.employer to rl_sam1_ro;

grant select on samqa.employer to rl_sam_rw;

grant select on samqa.employer to rl_sam_ro;

grant select on samqa.employer to reportdb_ro;

grant update on samqa.employer to rl_sam_rw;

