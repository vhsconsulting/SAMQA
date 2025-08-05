-- liquibase formatted sql
-- changeset SAMQA:1754373944084 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_plan_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_plan_type.sql:null:c8d40236af12327922a92b4b3bcf3e6f7f6bb201:create

grant select on samqa.fsa_hra_plan_type to rl_sam1_ro;

grant select on samqa.fsa_hra_plan_type to rl_sam_rw;

grant select on samqa.fsa_hra_plan_type to rl_sam_ro;

grant select on samqa.fsa_hra_plan_type to sgali;

