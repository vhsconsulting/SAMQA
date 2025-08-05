-- liquibase formatted sql
-- changeset SAMQA:1754373943876 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.expense_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.expense_type.sql:null:d62ce40a2cbf6969059d7d5d4ee90a087523bda0:create

grant select on samqa.expense_type to rl_sam1_ro;

grant select on samqa.expense_type to rl_sam_rw;

grant select on samqa.expense_type to rl_sam_ro;

grant select on samqa.expense_type to sgali;

