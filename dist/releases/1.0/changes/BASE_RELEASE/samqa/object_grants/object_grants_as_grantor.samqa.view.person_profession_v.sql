-- liquibase formatted sql
-- changeset SAMQA:1754373944906 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.person_profession_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.person_profession_v.sql:null:fe3d82a904a658fad75301095909d00c3cbc52ce:create

grant select on samqa.person_profession_v to rl_sam1_ro;

grant select on samqa.person_profession_v to rl_sam_rw;

grant select on samqa.person_profession_v to rl_sam_ro;

grant select on samqa.person_profession_v to sgali;

