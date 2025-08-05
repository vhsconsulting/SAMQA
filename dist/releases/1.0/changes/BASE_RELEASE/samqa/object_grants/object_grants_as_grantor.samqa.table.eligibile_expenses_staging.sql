-- liquibase formatted sql
-- changeset SAMQA:1754373939843 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eligibile_expenses_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eligibile_expenses_staging.sql:null:6de94f58004711ba73ab6c8c3fec755d7b160242:create

grant delete on samqa.eligibile_expenses_staging to rl_sam_rw;

grant insert on samqa.eligibile_expenses_staging to rl_sam_rw;

grant select on samqa.eligibile_expenses_staging to rl_sam1_ro;

grant select on samqa.eligibile_expenses_staging to rl_sam_rw;

grant select on samqa.eligibile_expenses_staging to rl_sam_ro;

grant update on samqa.eligibile_expenses_staging to rl_sam_rw;

