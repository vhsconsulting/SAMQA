-- liquibase formatted sql
-- changeset SAMQA:1754373944434 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.incomplete_account_funds_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.incomplete_account_funds_v.sql:null:16b8c856a2722aca747c9b19e63c1566b3f1977d:create

grant select on samqa.incomplete_account_funds_v to rl_sam1_ro;

grant select on samqa.incomplete_account_funds_v to rl_sam_rw;

grant select on samqa.incomplete_account_funds_v to rl_sam_ro;

grant select on samqa.incomplete_account_funds_v to sgali;

