-- liquibase formatted sql
-- changeset SAMQA:1754373940208 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.entrp_relationships_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.entrp_relationships_staging.sql:null:5ef7af1b18eff1457e21701b12c98d09546ace05:create

grant delete on samqa.entrp_relationships_staging to rl_sam_rw;

grant insert on samqa.entrp_relationships_staging to rl_sam_rw;

grant select on samqa.entrp_relationships_staging to rl_sam1_ro;

grant select on samqa.entrp_relationships_staging to rl_sam_rw;

grant select on samqa.entrp_relationships_staging to rl_sam_ro;

grant update on samqa.entrp_relationships_staging to rl_sam_rw;

