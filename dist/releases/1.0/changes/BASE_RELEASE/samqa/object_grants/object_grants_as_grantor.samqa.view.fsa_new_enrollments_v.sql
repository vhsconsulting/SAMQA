-- liquibase formatted sql
-- changeset SAMQA:1754373944134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_new_enrollments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_new_enrollments_v.sql:null:de146d4969fcee6424db236c8249fbace519d245:create

grant select on samqa.fsa_new_enrollments_v to rl_sam1_ro;

grant select on samqa.fsa_new_enrollments_v to rl_sam_rw;

grant select on samqa.fsa_new_enrollments_v to rl_sam_ro;

grant select on samqa.fsa_new_enrollments_v to sgali;

