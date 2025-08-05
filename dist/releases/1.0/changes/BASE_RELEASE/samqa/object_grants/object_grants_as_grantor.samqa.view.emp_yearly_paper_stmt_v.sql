-- liquibase formatted sql
-- changeset SAMQA:1754373943669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_yearly_paper_stmt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_yearly_paper_stmt_v.sql:null:887b2bdfee7ddc578ba8d0e268f24018937c8377:create

grant select on samqa.emp_yearly_paper_stmt_v to rl_sam1_ro;

grant select on samqa.emp_yearly_paper_stmt_v to rl_sam_rw;

grant select on samqa.emp_yearly_paper_stmt_v to rl_sam_ro;

grant select on samqa.emp_yearly_paper_stmt_v to sgali;

