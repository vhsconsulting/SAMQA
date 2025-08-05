-- liquibase formatted sql
-- changeset SAMQA:1754373938854 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bankserv_txn_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bankserv_txn_external.sql:null:6bf7895adbef3314d489377fd4bdd2ae3d774342:create

grant select on samqa.bankserv_txn_external to rl_sam1_ro;

grant select on samqa.bankserv_txn_external to rl_sam_ro;

