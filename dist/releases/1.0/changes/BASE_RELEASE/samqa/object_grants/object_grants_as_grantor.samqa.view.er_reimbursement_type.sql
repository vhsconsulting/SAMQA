-- liquibase formatted sql
-- changeset SAMQA:1754373943852 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_reimbursement_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_reimbursement_type.sql:null:8d8feba8dd179f7ee9b0056c155b660ff76ba9af:create

grant select on samqa.er_reimbursement_type to rl_sam1_ro;

grant select on samqa.er_reimbursement_type to rl_sam_rw;

grant select on samqa.er_reimbursement_type to rl_sam_ro;

grant select on samqa.er_reimbursement_type to sgali;

