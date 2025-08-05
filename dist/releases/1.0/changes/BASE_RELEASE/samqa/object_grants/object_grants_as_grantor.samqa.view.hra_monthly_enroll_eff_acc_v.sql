-- liquibase formatted sql
-- changeset SAMQA:1754373944276 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_monthly_enroll_eff_acc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_monthly_enroll_eff_acc_v.sql:null:db403d2379f2124a2501a7410d72c78cc268e620:create

grant select on samqa.hra_monthly_enroll_eff_acc_v to rl_sam1_ro;

grant select on samqa.hra_monthly_enroll_eff_acc_v to rl_sam_rw;

grant select on samqa.hra_monthly_enroll_eff_acc_v to rl_sam_ro;

grant select on samqa.hra_monthly_enroll_eff_acc_v to sgali;

