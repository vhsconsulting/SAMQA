-- liquibase formatted sql
-- changeset SAMQA:1754373944285 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_monthly_enrollment_acc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_monthly_enrollment_acc_v.sql:null:95bc0be1449e539b0492f90d465f96c081104ff2:create

grant select on samqa.hra_monthly_enrollment_acc_v to rl_sam1_ro;

grant select on samqa.hra_monthly_enrollment_acc_v to rl_sam_rw;

grant select on samqa.hra_monthly_enrollment_acc_v to rl_sam_ro;

grant select on samqa.hra_monthly_enrollment_acc_v to sgali;

