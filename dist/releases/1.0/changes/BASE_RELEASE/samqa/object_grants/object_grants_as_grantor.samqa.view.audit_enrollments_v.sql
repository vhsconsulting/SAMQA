-- liquibase formatted sql
-- changeset SAMQA:1754373942927 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.audit_enrollments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.audit_enrollments_v.sql:null:67874b2a18018fbeb0b70cdde36115d9ec0d0454:create

grant select on samqa.audit_enrollments_v to rl_sam1_ro;

grant select on samqa.audit_enrollments_v to rl_sam_rw;

grant select on samqa.audit_enrollments_v to rl_sam_ro;

grant select on samqa.audit_enrollments_v to sgali;

