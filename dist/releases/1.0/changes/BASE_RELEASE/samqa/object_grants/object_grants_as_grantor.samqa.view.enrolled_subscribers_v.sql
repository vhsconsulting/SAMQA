-- liquibase formatted sql
-- changeset SAMQA:1754373943765 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.enrolled_subscribers_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.enrolled_subscribers_v.sql:null:2c78098e15ce40feeefe728e5131e5125c7ba14a:create

grant select on samqa.enrolled_subscribers_v to rl_sam1_ro;

grant select on samqa.enrolled_subscribers_v to rl_sam_rw;

grant select on samqa.enrolled_subscribers_v to rl_sam_ro;

grant select on samqa.enrolled_subscribers_v to sgali;

