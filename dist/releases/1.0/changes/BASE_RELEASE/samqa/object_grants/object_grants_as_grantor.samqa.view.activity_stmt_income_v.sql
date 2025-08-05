-- liquibase formatted sql
-- changeset SAMQA:1754373942864 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.activity_stmt_income_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.activity_stmt_income_v.sql:null:f634966a24fb330dcf0a11195bf564c745b0d13f:create

grant select on samqa.activity_stmt_income_v to rl_sam1_ro;

grant select on samqa.activity_stmt_income_v to rl_sam_rw;

grant select on samqa.activity_stmt_income_v to rl_sam_ro;

grant select on samqa.activity_stmt_income_v to sgali;

