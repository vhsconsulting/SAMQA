-- liquibase formatted sql
-- changeset SAMQA:1754373943870 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.expense_category.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.expense_category.sql:null:d78381adf5b4358b15b9510b58f48bb1efb99a43:create

grant select on samqa.expense_category to rl_sam1_ro;

grant select on samqa.expense_category to rl_sam_rw;

grant select on samqa.expense_category to rl_sam_ro;

grant select on samqa.expense_category to sgali;

