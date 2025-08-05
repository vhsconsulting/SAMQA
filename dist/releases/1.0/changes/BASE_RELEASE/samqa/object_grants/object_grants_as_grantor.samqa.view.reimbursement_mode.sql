-- liquibase formatted sql
-- changeset SAMQA:1754373945034 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.reimbursement_mode.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.reimbursement_mode.sql:null:42053826aac6b3c1714656b6a13fc1467a473668:create

grant select on samqa.reimbursement_mode to rl_sam1_ro;

grant select on samqa.reimbursement_mode to rl_sam_rw;

grant select on samqa.reimbursement_mode to rl_sam_ro;

grant select on samqa.reimbursement_mode to sgali;

