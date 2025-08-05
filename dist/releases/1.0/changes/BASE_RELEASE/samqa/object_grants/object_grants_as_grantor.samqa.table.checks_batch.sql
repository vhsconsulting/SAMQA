-- liquibase formatted sql
-- changeset SAMQA:1754373939254 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.checks_batch.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.checks_batch.sql:null:0ad39cb44c71469688981ef161f09fd7809db2fa:create

grant alter on samqa.checks_batch to public;

grant delete on samqa.checks_batch to public;

grant index on samqa.checks_batch to public;

grant insert on samqa.checks_batch to public;

grant select on samqa.checks_batch to public;

grant select on samqa.checks_batch to rl_sam_ro;

grant update on samqa.checks_batch to public;

grant references on samqa.checks_batch to public;

grant read on samqa.checks_batch to public;

grant on commit refresh on samqa.checks_batch to public;

grant query rewrite on samqa.checks_batch to public;

grant debug on samqa.checks_batch to public;

grant flashback on samqa.checks_batch to public;

