-- liquibase formatted sql
-- changeset SAMQA:1754373936697 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.change_vendor.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.change_vendor.sql:null:c9d1a6027e319fcf140f2f10bc30f2781507cdb2:create

grant execute on samqa.change_vendor to rl_sam_ro;

grant execute on samqa.change_vendor to rl_sam_rw;

grant execute on samqa.change_vendor to rl_sam1_ro;

grant debug on samqa.change_vendor to sgali;

grant debug on samqa.change_vendor to rl_sam_rw;

grant debug on samqa.change_vendor to rl_sam1_ro;

