-- liquibase formatted sql
-- changeset SAMQA:1754373944159 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_plans_enroll_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_plans_enroll_v.sql:null:047af29672944d8d747f3bf2a43c93d152c4c923:create

grant select on samqa.fsa_plans_enroll_v to rl_sam1_ro;

grant select on samqa.fsa_plans_enroll_v to rl_sam_rw;

grant select on samqa.fsa_plans_enroll_v to rl_sam_ro;

grant select on samqa.fsa_plans_enroll_v to sgali;

