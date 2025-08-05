-- liquibase formatted sql
-- changeset SAMQA:1754373944185 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsahra_contribution_summary_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsahra_contribution_summary_v.sql:null:137a3a54ee6e79265bcb85bbb56438e765c2f246:create

grant select on samqa.fsahra_contribution_summary_v to rl_sam1_ro;

grant select on samqa.fsahra_contribution_summary_v to rl_sam_rw;

grant select on samqa.fsahra_contribution_summary_v to rl_sam_ro;

grant select on samqa.fsahra_contribution_summary_v to sgali;

