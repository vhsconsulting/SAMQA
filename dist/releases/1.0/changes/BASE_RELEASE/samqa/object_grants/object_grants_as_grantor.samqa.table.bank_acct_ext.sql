-- liquibase formatted sql
-- changeset SAMQA:1754373938828 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bank_acct_ext.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bank_acct_ext.sql:null:3a22585812a501b5e194368bc521bf65bd0b2b17:create

grant select on samqa.bank_acct_ext to rl_sam1_ro;

grant select on samqa.bank_acct_ext to rl_sam_ro;

