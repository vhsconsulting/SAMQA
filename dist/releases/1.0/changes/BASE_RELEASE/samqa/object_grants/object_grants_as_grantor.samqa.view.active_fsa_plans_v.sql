-- liquibase formatted sql
-- changeset SAMQA:1754373942848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.active_fsa_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.active_fsa_plans_v.sql:null:2c7956e576d469768943419628a18a5117618f36:create

grant select on samqa.active_fsa_plans_v to rl_sam1_ro;

grant select on samqa.active_fsa_plans_v to rl_sam_rw;

grant select on samqa.active_fsa_plans_v to rl_sam_ro;

grant select on samqa.active_fsa_plans_v to sgali;

