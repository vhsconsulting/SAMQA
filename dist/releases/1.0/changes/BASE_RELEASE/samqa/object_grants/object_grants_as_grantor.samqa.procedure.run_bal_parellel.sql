-- liquibase formatted sql
-- changeset SAMQA:1754373937122 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.run_bal_parellel.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.run_bal_parellel.sql:null:cc25580953c4ce98889906c14cfd447c46d0b53a:create

grant execute on samqa.run_bal_parellel to rl_sam_ro;

grant execute on samqa.run_bal_parellel to rl_sam_rw;

grant execute on samqa.run_bal_parellel to rl_sam1_ro;

grant debug on samqa.run_bal_parellel to sgali;

grant debug on samqa.run_bal_parellel to rl_sam_rw;

grant debug on samqa.run_bal_parellel to rl_sam1_ro;

