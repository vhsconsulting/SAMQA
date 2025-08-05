-- liquibase formatted sql
-- changeset SAMQA:1754373939455 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_disbursements_bk1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_disbursements_bk1.sql:null:741c636559bbefd577ccf4b9a9571fe52234ae7b:create

grant delete on samqa.cobra_disbursements_bk1 to rl_sam_rw;

grant insert on samqa.cobra_disbursements_bk1 to rl_sam_rw;

grant select on samqa.cobra_disbursements_bk1 to rl_sam1_ro;

grant select on samqa.cobra_disbursements_bk1 to rl_sam_ro;

grant select on samqa.cobra_disbursements_bk1 to rl_sam_rw;

grant update on samqa.cobra_disbursements_bk1 to rl_sam_rw;

