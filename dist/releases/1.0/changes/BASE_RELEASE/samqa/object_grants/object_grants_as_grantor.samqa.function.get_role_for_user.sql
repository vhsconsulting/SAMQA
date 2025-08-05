-- liquibase formatted sql
-- changeset SAMQA:1754373935386 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_role_for_user.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_role_for_user.sql:null:3e92e83057a9a648819c2e33c60a53a346e9f721:create

grant execute on samqa.get_role_for_user to rl_sam_ro;

grant execute on samqa.get_role_for_user to rl_sam_rw;

grant execute on samqa.get_role_for_user to rl_sam1_ro;

grant debug on samqa.get_role_for_user to sgali;

grant debug on samqa.get_role_for_user to rl_sam_rw;

grant debug on samqa.get_role_for_user to rl_sam1_ro;

