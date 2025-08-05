-- liquibase formatted sql
-- changeset SAMQA:1754373938823 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bank_accounts_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bank_accounts_external.sql:null:5110788c8b1feaf0126c3182474a3cf04cabbc3d:create

grant select on samqa.bank_accounts_external to rl_sam1_ro;

grant select on samqa.bank_accounts_external to rl_sam_ro;

