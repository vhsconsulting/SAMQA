-- liquibase formatted sql
-- changeset SAMQA:1754373944141 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_plan_info_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_plan_info_v.sql:null:bed8e90071f1facb131918d447815531e3780596:create

grant select on samqa.fsa_plan_info_v to rl_sam1_ro;

grant select on samqa.fsa_plan_info_v to rl_sam_rw;

grant select on samqa.fsa_plan_info_v to rl_sam_ro;

grant select on samqa.fsa_plan_info_v to sgali;

