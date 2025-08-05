-- liquibase formatted sql
-- changeset SAMQA:1754373943663 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_user_profile_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_user_profile_v.sql:null:b593122f8b9e1605fb9f27a699d0c5a8484e4a1c:create

grant select on samqa.emp_user_profile_v to rl_sam1_ro;

grant select on samqa.emp_user_profile_v to rl_sam_rw;

grant select on samqa.emp_user_profile_v to rl_sam_ro;

grant select on samqa.emp_user_profile_v to sgali;

