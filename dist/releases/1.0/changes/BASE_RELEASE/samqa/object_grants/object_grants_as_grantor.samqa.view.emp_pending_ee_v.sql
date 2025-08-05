-- liquibase formatted sql
-- changeset SAMQA:1754373943630 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_pending_ee_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_pending_ee_v.sql:null:800be67aaff64767eae086bd55c2c260df0c0696:create

grant select on samqa.emp_pending_ee_v to rl_sam1_ro;

grant select on samqa.emp_pending_ee_v to rl_sam_rw;

grant select on samqa.emp_pending_ee_v to rl_sam_ro;

grant select on samqa.emp_pending_ee_v to sgali;

