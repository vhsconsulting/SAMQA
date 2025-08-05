-- liquibase formatted sql
-- changeset SAMQA:1754373935527 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.password_verify_function.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.password_verify_function.sql:null:99633260f693a81b20db0f27f914f614b72da073:create

grant execute on samqa.password_verify_function to rl_sam_ro;

grant execute on samqa.password_verify_function to rl_sam_rw;

grant execute on samqa.password_verify_function to rl_sam1_ro;

grant debug on samqa.password_verify_function to sgali;

grant debug on samqa.password_verify_function to rl_sam_rw;

grant debug on samqa.password_verify_function to rl_sam1_ro;

