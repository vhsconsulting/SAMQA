-- liquibase formatted sql
-- changeset SAMQA:1754373935536 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.phonekeypad_char.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.phonekeypad_char.sql:null:288f443b35b55090552f13d443266d39b6d1037d:create

grant execute on samqa.phonekeypad_char to rl_sam_ro;

grant execute on samqa.phonekeypad_char to rl_sam_rw;

grant execute on samqa.phonekeypad_char to rl_sam1_ro;

grant debug on samqa.phonekeypad_char to sgali;

grant debug on samqa.phonekeypad_char to rl_sam_rw;

grant debug on samqa.phonekeypad_char to rl_sam1_ro;

