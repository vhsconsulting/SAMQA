-- liquibase formatted sql
-- changeset SAMQA:1754373940248 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_eligible_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_eligible_staging.sql:null:c551dcd377fcebdc7da2d6e9731eb6cee015900c:create

grant delete on samqa.eob_eligible_staging to rl_sam_rw;

grant insert on samqa.eob_eligible_staging to rl_sam_rw;

grant select on samqa.eob_eligible_staging to rl_sam1_ro;

grant select on samqa.eob_eligible_staging to rl_sam_rw;

grant select on samqa.eob_eligible_staging to rl_sam_ro;

grant update on samqa.eob_eligible_staging to rl_sam_rw;

