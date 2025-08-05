-- liquibase formatted sql
-- changeset SAMQA:1754373943637 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_prev_adj_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_prev_adj_v.sql:null:95e1afc60ad1a82fa58d74db86074c445ce961fa:create

grant select on samqa.emp_prev_adj_v to rl_sam1_ro;

grant select on samqa.emp_prev_adj_v to rl_sam_rw;

grant select on samqa.emp_prev_adj_v to rl_sam_ro;

grant select on samqa.emp_prev_adj_v to sgali;

