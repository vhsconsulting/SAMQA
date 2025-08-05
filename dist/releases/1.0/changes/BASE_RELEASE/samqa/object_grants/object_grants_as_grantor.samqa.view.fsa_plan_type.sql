-- liquibase formatted sql
-- changeset SAMQA:1754373944152 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_plan_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_plan_type.sql:null:adeb9dbc2d02256b684ec1dc514b13fcd4c99263:create

grant select on samqa.fsa_plan_type to rl_sam1_ro;

grant select on samqa.fsa_plan_type to rl_sam_rw;

grant select on samqa.fsa_plan_type to rl_sam_ro;

grant select on samqa.fsa_plan_type to sgali;

