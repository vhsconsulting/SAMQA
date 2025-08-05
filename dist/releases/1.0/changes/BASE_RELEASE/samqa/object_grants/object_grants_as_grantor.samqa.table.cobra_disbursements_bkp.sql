-- liquibase formatted sql
-- changeset SAMQA:1754373939463 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_disbursements_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_disbursements_bkp.sql:null:7233f6815d2eb88ab95b2e8b432f9b9275b81737:create

grant delete on samqa.cobra_disbursements_bkp to rl_sam_rw;

grant insert on samqa.cobra_disbursements_bkp to rl_sam_rw;

grant select on samqa.cobra_disbursements_bkp to rl_sam1_ro;

grant select on samqa.cobra_disbursements_bkp to rl_sam_ro;

grant select on samqa.cobra_disbursements_bkp to rl_sam_rw;

grant update on samqa.cobra_disbursements_bkp to rl_sam_rw;

