-- liquibase formatted sql
-- changeset SAMQA:1754373943108 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_profile_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_profile_v.sql:null:57f4fa7c83202a738e7832f52afdba0b2ac98dd2:create

grant select on samqa.broker_profile_v to rl_sam1_ro;

grant select on samqa.broker_profile_v to rl_sam_rw;

grant select on samqa.broker_profile_v to rl_sam_ro;

grant select on samqa.broker_profile_v to sgali;

