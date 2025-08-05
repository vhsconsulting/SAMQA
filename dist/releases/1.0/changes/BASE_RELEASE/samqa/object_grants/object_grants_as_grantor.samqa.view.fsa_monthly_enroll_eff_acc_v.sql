-- liquibase formatted sql
-- changeset SAMQA:1754373944120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_monthly_enroll_eff_acc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_monthly_enroll_eff_acc_v.sql:null:7f703c351860a9261e0648cdda50008221c9abd6:create

grant select on samqa.fsa_monthly_enroll_eff_acc_v to rl_sam1_ro;

grant select on samqa.fsa_monthly_enroll_eff_acc_v to rl_sam_rw;

grant select on samqa.fsa_monthly_enroll_eff_acc_v to rl_sam_ro;

grant select on samqa.fsa_monthly_enroll_eff_acc_v to sgali;

