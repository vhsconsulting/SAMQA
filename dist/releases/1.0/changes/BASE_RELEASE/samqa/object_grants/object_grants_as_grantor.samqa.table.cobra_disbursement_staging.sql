-- liquibase formatted sql
-- changeset SAMQA:1754373939416 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_disbursement_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_disbursement_staging.sql:null:5ceb77f4ad06358ecaa1e9b3d04058d8e2db2aa9:create

grant delete on samqa.cobra_disbursement_staging to rl_sam_rw;

grant insert on samqa.cobra_disbursement_staging to rl_sam_rw;

grant select on samqa.cobra_disbursement_staging to rl_sam1_ro;

grant select on samqa.cobra_disbursement_staging to rl_sam_rw;

grant select on samqa.cobra_disbursement_staging to rl_sam_ro;

grant update on samqa.cobra_disbursement_staging to rl_sam_rw;

