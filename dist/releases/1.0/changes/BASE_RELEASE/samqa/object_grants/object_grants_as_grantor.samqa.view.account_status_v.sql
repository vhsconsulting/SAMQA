-- liquibase formatted sql
-- changeset SAMQA:1754373942769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_status_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_status_v.sql:null:7a8e7f63a67029963413f37892e4053d131d542f:create

grant select on samqa.account_status_v to rl_sam1_ro;

grant select on samqa.account_status_v to rl_sam_rw;

grant select on samqa.account_status_v to rl_sam_ro;

grant select on samqa.account_status_v to sgali;

