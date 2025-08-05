-- liquibase formatted sql
-- changeset SAMQA:1754373944906 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.person_title_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.person_title_v.sql:null:f822728d9c33c392d763ee5e12e2a6199b87907e:create

grant select on samqa.person_title_v to rl_sam1_ro;

grant select on samqa.person_title_v to rl_sam_rw;

grant select on samqa.person_title_v to rl_sam_ro;

grant select on samqa.person_title_v to sgali;

