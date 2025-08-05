-- liquibase formatted sql
-- changeset SAMQA:1754373943166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cancelled_contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cancelled_contribution_v.sql:null:327a37b94c31daecdbee949db7f5552bc6303995:create

grant select on samqa.cancelled_contribution_v to rl_sam1_ro;

grant select on samqa.cancelled_contribution_v to rl_sam_rw;

grant select on samqa.cancelled_contribution_v to rl_sam_ro;

grant select on samqa.cancelled_contribution_v to sgali;

