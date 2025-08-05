-- liquibase formatted sql
-- changeset SAMQA:1754373942727 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_user_profile_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_user_profile_v.sql:null:c5105640118841fc2e90b66b9cd57911817e2ee2:create

grant select on samqa.acc_user_profile_v to rl_sam1_ro;

grant select on samqa.acc_user_profile_v to rl_sam_rw;

grant select on samqa.acc_user_profile_v to rl_sam_ro;

grant select on samqa.acc_user_profile_v to sgali;

