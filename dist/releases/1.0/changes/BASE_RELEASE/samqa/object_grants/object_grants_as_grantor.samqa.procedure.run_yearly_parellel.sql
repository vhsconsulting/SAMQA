-- liquibase formatted sql
-- changeset SAMQA:1754373937147 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.run_yearly_parellel.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.run_yearly_parellel.sql:null:4a1706d2040eda4121cd8d70026e4add5c7d44e9:create

grant execute on samqa.run_yearly_parellel to rl_sam_ro;

grant execute on samqa.run_yearly_parellel to rl_sam_rw;

grant execute on samqa.run_yearly_parellel to rl_sam1_ro;

grant debug on samqa.run_yearly_parellel to sgali;

grant debug on samqa.run_yearly_parellel to rl_sam_rw;

grant debug on samqa.run_yearly_parellel to rl_sam1_ro;

