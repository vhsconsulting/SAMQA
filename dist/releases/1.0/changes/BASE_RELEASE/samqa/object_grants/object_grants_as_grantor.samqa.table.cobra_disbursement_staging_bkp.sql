-- liquibase formatted sql
-- changeset SAMQA:1754373939431 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_disbursement_staging_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_disbursement_staging_bkp.sql:null:bfe500d80cb267ef37e11f95372799c60cd59e94:create

grant delete on samqa.cobra_disbursement_staging_bkp to rl_sam_rw;

grant insert on samqa.cobra_disbursement_staging_bkp to rl_sam_rw;

grant select on samqa.cobra_disbursement_staging_bkp to rl_sam1_ro;

grant select on samqa.cobra_disbursement_staging_bkp to rl_sam_ro;

grant select on samqa.cobra_disbursement_staging_bkp to rl_sam_rw;

grant update on samqa.cobra_disbursement_staging_bkp to rl_sam_rw;

