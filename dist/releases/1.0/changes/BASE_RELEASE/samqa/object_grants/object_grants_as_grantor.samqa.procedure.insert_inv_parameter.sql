-- liquibase formatted sql
-- changeset SAMQA:1754373936903 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.insert_inv_parameter.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.insert_inv_parameter.sql:null:721a175f881e8a6a442fde347ddba5147e9dd39b:create

grant execute on samqa.insert_inv_parameter to rl_sam_ro;

grant execute on samqa.insert_inv_parameter to rl_sam_rw;

grant execute on samqa.insert_inv_parameter to rl_sam1_ro;

grant debug on samqa.insert_inv_parameter to sgali;

grant debug on samqa.insert_inv_parameter to rl_sam_rw;

grant debug on samqa.insert_inv_parameter to rl_sam1_ro;

