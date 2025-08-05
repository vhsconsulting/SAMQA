-- liquibase formatted sql
-- changeset SAMQA:1754373943650 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_quarterly_paper_stmt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_quarterly_paper_stmt_v.sql:null:09aafe3a31081cbfabb0473cd50782c9495d3f00:create

grant select on samqa.emp_quarterly_paper_stmt_v to rl_sam1_ro;

grant select on samqa.emp_quarterly_paper_stmt_v to rl_sam_rw;

grant select on samqa.emp_quarterly_paper_stmt_v to rl_sam_ro;

grant select on samqa.emp_quarterly_paper_stmt_v to sgali;

