-- liquibase formatted sql
-- changeset SAMQA:1754373943999 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_enrollments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_enrollments_v.sql:null:e711ec271b90e181361c6f906a7f70524c91ced1:create

grant select on samqa.fsa_enrollments_v to rl_sam1_ro;

grant select on samqa.fsa_enrollments_v to rl_sam_rw;

grant select on samqa.fsa_enrollments_v to rl_sam_ro;

grant select on samqa.fsa_enrollments_v to sgali;

