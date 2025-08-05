-- liquibase formatted sql
-- changeset SAMQA:1754373944126 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_monthly_enrollment_acc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_monthly_enrollment_acc_v.sql:null:c027245f1758abf274115ac6fda9c2741f47bd2a:create

grant select on samqa.fsa_monthly_enrollment_acc_v to rl_sam1_ro;

grant select on samqa.fsa_monthly_enrollment_acc_v to rl_sam_rw;

grant select on samqa.fsa_monthly_enrollment_acc_v to rl_sam_ro;

grant select on samqa.fsa_monthly_enrollment_acc_v to sgali;

