-- liquibase formatted sql
-- changeset SAMQA:1754373936862 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.generate_1099.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.generate_1099.sql:null:c2642757080805b22311fc4f139a3b105aae0dff:create

grant execute on samqa.generate_1099 to rl_sam_ro;

grant execute on samqa.generate_1099 to rl_sam_rw;

grant execute on samqa.generate_1099 to public;

grant execute on samqa.generate_1099 to rl_sam1_ro;

grant debug on samqa.generate_1099 to sgali;

grant debug on samqa.generate_1099 to rl_sam_rw;

grant debug on samqa.generate_1099 to rl_sam1_ro;

