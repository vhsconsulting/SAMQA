-- liquibase formatted sql
-- changeset SAMQA:1754373944875 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.pending_contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.pending_contribution_v.sql:null:42681d3f0cb64b8efaa86ccf1e11e2e7b559f638:create

grant select on samqa.pending_contribution_v to rl_sam1_ro;

grant select on samqa.pending_contribution_v to rl_sam_rw;

grant select on samqa.pending_contribution_v to rl_sam_ro;

grant select on samqa.pending_contribution_v to sgali;

