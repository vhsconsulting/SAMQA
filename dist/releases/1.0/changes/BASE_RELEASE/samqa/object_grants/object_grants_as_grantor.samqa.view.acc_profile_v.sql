-- liquibase formatted sql
-- changeset SAMQA:1754373942703 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_profile_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_profile_v.sql:null:0f40542cff22610fdf796c147831fce846ef6881:create

grant select on samqa.acc_profile_v to rl_sam1_ro;

grant select on samqa.acc_profile_v to rl_sam_rw;

grant select on samqa.acc_profile_v to rl_sam_ro;

grant select on samqa.acc_profile_v to sgali;

