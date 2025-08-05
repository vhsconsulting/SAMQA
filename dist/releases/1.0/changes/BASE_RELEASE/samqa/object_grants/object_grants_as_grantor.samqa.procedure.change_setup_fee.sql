-- liquibase formatted sql
-- changeset SAMQA:1754373936690 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.change_setup_fee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.change_setup_fee.sql:null:65c400771c86d5677d3dcd7a55a6eedbecaf82d3:create

grant execute on samqa.change_setup_fee to rl_sam_ro;

grant execute on samqa.change_setup_fee to rl_sam_rw;

grant execute on samqa.change_setup_fee to rl_sam1_ro;

grant debug on samqa.change_setup_fee to sgali;

grant debug on samqa.change_setup_fee to rl_sam_rw;

grant debug on samqa.change_setup_fee to rl_sam1_ro;

