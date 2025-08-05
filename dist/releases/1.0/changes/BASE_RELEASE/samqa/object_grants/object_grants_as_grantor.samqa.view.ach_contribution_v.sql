-- liquibase formatted sql
-- changeset SAMQA:1754373942795 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ach_contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ach_contribution_v.sql:null:46a5aaee1cfecbc383838bcc15d393b916b848a9:create

grant select on samqa.ach_contribution_v to rl_sam1_ro;

grant select on samqa.ach_contribution_v to rl_sam_rw;

grant select on samqa.ach_contribution_v to rl_sam_ro;

grant select on samqa.ach_contribution_v to sgali;

