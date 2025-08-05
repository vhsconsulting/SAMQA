-- liquibase formatted sql
-- changeset SAMQA:1754373942714 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_quarterly_paper_stmt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_quarterly_paper_stmt_v.sql:null:5b480f3c32e48680c398fa6b687a8244dd873b9c:create

grant select on samqa.acc_quarterly_paper_stmt_v to rl_sam1_ro;

grant select on samqa.acc_quarterly_paper_stmt_v to rl_sam_rw;

grant select on samqa.acc_quarterly_paper_stmt_v to rl_sam_ro;

grant select on samqa.acc_quarterly_paper_stmt_v to sgali;

