-- liquibase formatted sql
-- changeset SAMQA:1754373944173 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_uploaded_plan_types_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_uploaded_plan_types_v.sql:null:e0ae26bcf824332f29a0b85338c6911c8b29e6d0:create

grant select on samqa.fsa_uploaded_plan_types_v to rl_sam1_ro;

grant select on samqa.fsa_uploaded_plan_types_v to rl_sam_rw;

grant select on samqa.fsa_uploaded_plan_types_v to rl_sam_ro;

grant select on samqa.fsa_uploaded_plan_types_v to sgali;

