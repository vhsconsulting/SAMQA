-- liquibase formatted sql
-- changeset SAMQA:1754373939065 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_account_ns_rev_5yr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_account_ns_rev_5yr.sql:null:f60f6bb48cb5f0fbdae82c264d8902cc5becfa1c:create

grant select on samqa.broker_account_ns_rev_5yr to rl_sam_ro;

grant debug on samqa.broker_account_ns_rev_5yr to rl_sam_ro;

