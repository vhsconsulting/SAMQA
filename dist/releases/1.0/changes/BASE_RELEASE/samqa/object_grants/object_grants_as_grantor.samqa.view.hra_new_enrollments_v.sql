-- liquibase formatted sql
-- changeset SAMQA:1754373944294 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_new_enrollments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_new_enrollments_v.sql:null:fd4833bf2f77f9e21a9688a46b88948c3ca53ff1:create

grant select on samqa.hra_new_enrollments_v to rl_sam1_ro;

grant select on samqa.hra_new_enrollments_v to rl_sam_rw;

grant select on samqa.hra_new_enrollments_v to rl_sam_ro;

grant select on samqa.hra_new_enrollments_v to sgali;

