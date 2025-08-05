-- liquibase formatted sql
-- changeset SAMQA:1754373944100 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_rollover_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_rollover_v.sql:null:dfdb68ec6e4605124917c7de228ab354bb935f0d:create

grant select on samqa.fsa_hra_rollover_v to rl_sam1_ro;

grant select on samqa.fsa_hra_rollover_v to rl_sam_rw;

grant select on samqa.fsa_hra_rollover_v to rl_sam_ro;

grant select on samqa.fsa_hra_rollover_v to sgali;

