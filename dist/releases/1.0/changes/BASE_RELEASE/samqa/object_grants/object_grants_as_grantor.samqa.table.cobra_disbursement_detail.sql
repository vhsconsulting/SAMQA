-- liquibase formatted sql
-- changeset SAMQA:1754373939408 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_disbursement_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_disbursement_detail.sql:null:1d6f741c697c9758ccdcf96c087a06fe08c7d311:create

grant delete on samqa.cobra_disbursement_detail to rl_sam_rw;

grant insert on samqa.cobra_disbursement_detail to rl_sam_rw;

grant select on samqa.cobra_disbursement_detail to rl_sam1_ro;

grant select on samqa.cobra_disbursement_detail to rl_sam_rw;

grant select on samqa.cobra_disbursement_detail to rl_sam_ro;

grant update on samqa.cobra_disbursement_detail to rl_sam_rw;

