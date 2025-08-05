-- liquibase formatted sql
-- changeset SAMQA:1754373935821 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_account_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_account_details.sql:null:3c38875b64517ad1f8dfcb43df4d6dcadacd9ac7:create

grant execute on samqa.pc_account_details to rl_sam_ro;

grant execute on samqa.pc_account_details to rl_sam_rw;

grant execute on samqa.pc_account_details to rl_sam1_ro;

grant debug on samqa.pc_account_details to rl_sam_ro;

grant debug on samqa.pc_account_details to sgali;

grant debug on samqa.pc_account_details to rl_sam_rw;

grant debug on samqa.pc_account_details to rl_sam1_ro;

