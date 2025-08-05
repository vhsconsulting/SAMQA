-- liquibase formatted sql
-- changeset SAMQA:1754373944180 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_uploaded_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_uploaded_plans_v.sql:null:7132329006dc35eb76fcbedd72257009c37d94dd:create

grant select on samqa.fsa_uploaded_plans_v to rl_sam1_ro;

grant select on samqa.fsa_uploaded_plans_v to rl_sam_rw;

grant select on samqa.fsa_uploaded_plans_v to rl_sam_ro;

grant select on samqa.fsa_uploaded_plans_v to sgali;

