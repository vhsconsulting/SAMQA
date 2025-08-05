-- liquibase formatted sql
-- changeset SAMQA:1754373944036 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_ee_ben_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_ee_ben_plans_v.sql:null:f3c23da82b6b8fb1f368a86e4264afbe008f6b88:create

grant select on samqa.fsa_hra_ee_ben_plans_v to rl_sam1_ro;

grant select on samqa.fsa_hra_ee_ben_plans_v to rl_sam_rw;

grant select on samqa.fsa_hra_ee_ben_plans_v to rl_sam_ro;

grant select on samqa.fsa_hra_ee_ben_plans_v to sgali;

