-- liquibase formatted sql
-- changeset SAMQA:1754373942943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.bank_account_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.bank_account_type.sql:null:b396a8a7f7e6da03c736462d4c03f1e0a9021718:create

grant select on samqa.bank_account_type to rl_sam1_ro;

grant select on samqa.bank_account_type to rl_sam_rw;

grant select on samqa.bank_account_type to rl_sam_ro;

grant select on samqa.bank_account_type to sgali;

