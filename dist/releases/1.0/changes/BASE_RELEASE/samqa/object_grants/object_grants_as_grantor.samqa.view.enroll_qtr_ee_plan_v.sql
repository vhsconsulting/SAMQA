-- liquibase formatted sql
-- changeset SAMQA:1754373943752 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.enroll_qtr_ee_plan_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.enroll_qtr_ee_plan_v.sql:null:71d85d2b5eecd7d63512aeaf2c73d55659c86beb:create

grant select on samqa.enroll_qtr_ee_plan_v to rl_sam_rw;

grant select on samqa.enroll_qtr_ee_plan_v to rl_sam_ro;

grant select on samqa.enroll_qtr_ee_plan_v to sgali;

grant select on samqa.enroll_qtr_ee_plan_v to rl_sam1_ro;

