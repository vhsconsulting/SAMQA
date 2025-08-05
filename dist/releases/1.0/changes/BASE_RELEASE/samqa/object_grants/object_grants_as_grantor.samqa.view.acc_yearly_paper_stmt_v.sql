-- liquibase formatted sql
-- changeset SAMQA:1754373942733 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_yearly_paper_stmt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_yearly_paper_stmt_v.sql:null:84d215f2a4fd0000850cd4d00ca685e3a8895322:create

grant select on samqa.acc_yearly_paper_stmt_v to rl_sam1_ro;

grant select on samqa.acc_yearly_paper_stmt_v to rl_sam_rw;

grant select on samqa.acc_yearly_paper_stmt_v to rl_sam_ro;

grant select on samqa.acc_yearly_paper_stmt_v to sgali;

