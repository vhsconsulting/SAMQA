-- liquibase formatted sql
-- changeset SAMQA:1754373944064 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_er_ben_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_er_ben_plans_v.sql:null:87098e472d49adcf4afee14258ab5ed96ec4422b:create

grant select on samqa.fsa_hra_er_ben_plans_v to rl_sam1_ro;

grant select on samqa.fsa_hra_er_ben_plans_v to rl_sam_rw;

grant select on samqa.fsa_hra_er_ben_plans_v to rl_sam_ro;

grant select on samqa.fsa_hra_er_ben_plans_v to sgali;

