-- liquibase formatted sql
-- changeset SAMQA:1754373944268 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_fsa_ee_qtr_stmt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_fsa_ee_qtr_stmt_v.sql:null:4755dace1fc126da90c22313719e8270b2fdd147:create

grant select on samqa.hra_fsa_ee_qtr_stmt_v to rl_sam1_ro;

grant select on samqa.hra_fsa_ee_qtr_stmt_v to rl_sam_rw;

grant select on samqa.hra_fsa_ee_qtr_stmt_v to rl_sam_ro;

grant select on samqa.hra_fsa_ee_qtr_stmt_v to sgali;

