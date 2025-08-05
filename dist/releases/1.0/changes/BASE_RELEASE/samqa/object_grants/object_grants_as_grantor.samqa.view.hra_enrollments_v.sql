-- liquibase formatted sql
-- changeset SAMQA:1754373944251 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_enrollments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_enrollments_v.sql:null:9cb667df2a85d85dbe8c408f05f203c2766cbd20:create

grant select on samqa.hra_enrollments_v to rl_sam1_ro;

grant select on samqa.hra_enrollments_v to rl_sam_rw;

grant select on samqa.hra_enrollments_v to rl_sam_ro;

grant select on samqa.hra_enrollments_v to sgali;

