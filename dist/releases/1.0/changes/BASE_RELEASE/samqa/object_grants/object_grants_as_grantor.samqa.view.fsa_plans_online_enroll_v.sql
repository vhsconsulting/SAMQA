-- liquibase formatted sql
-- changeset SAMQA:1754373944166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_plans_online_enroll_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_plans_online_enroll_v.sql:null:975792be035e8daa837fa3d18f5e0afc9533ae8d:create

grant select on samqa.fsa_plans_online_enroll_v to rl_sam1_ro;

grant select on samqa.fsa_plans_online_enroll_v to rl_sam_rw;

grant select on samqa.fsa_plans_online_enroll_v to rl_sam_ro;

grant select on samqa.fsa_plans_online_enroll_v to sgali;

