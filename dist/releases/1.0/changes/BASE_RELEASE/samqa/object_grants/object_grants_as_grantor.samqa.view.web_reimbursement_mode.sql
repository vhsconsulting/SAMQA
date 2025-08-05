-- liquibase formatted sql
-- changeset SAMQA:1754373945427 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.web_reimbursement_mode.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.web_reimbursement_mode.sql:null:88c05dcb2bb0cf4ea02161d5681b5cfeff4de579:create

grant select on samqa.web_reimbursement_mode to rl_sam_rw;

grant select on samqa.web_reimbursement_mode to rl_sam_ro;

grant select on samqa.web_reimbursement_mode to sgali;

grant select on samqa.web_reimbursement_mode to rl_sam1_ro;

