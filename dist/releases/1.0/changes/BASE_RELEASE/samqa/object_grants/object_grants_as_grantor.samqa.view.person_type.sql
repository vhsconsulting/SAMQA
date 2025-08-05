-- liquibase formatted sql
-- changeset SAMQA:1754373944922 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.person_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.person_type.sql:null:7a7427cfbd5bc3d003a034265ca48fe4b78daf5c:create

grant select on samqa.person_type to rl_sam1_ro;

grant select on samqa.person_type to rl_sam_rw;

grant select on samqa.person_type to rl_sam_ro;

grant select on samqa.person_type to sgali;

