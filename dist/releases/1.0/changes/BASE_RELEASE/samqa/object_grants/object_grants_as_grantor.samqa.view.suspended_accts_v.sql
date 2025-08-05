-- liquibase formatted sql
-- changeset SAMQA:1754373945253 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.suspended_accts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.suspended_accts_v.sql:null:39363fe67e0b829e31492b44fe57572f15e74cd5:create

grant select on samqa.suspended_accts_v to rl_sam_rw;

grant select on samqa.suspended_accts_v to rl_sam_ro;

grant select on samqa.suspended_accts_v to sgali;

grant select on samqa.suspended_accts_v to rl_sam1_ro;

