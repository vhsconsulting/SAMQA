-- liquibase formatted sql
-- changeset SAMQA:1754373938861 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bankserv_txn_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bankserv_txn_staging.sql:null:2cfddd9f36eedbc00292fffba97e52bb393f9622:create

grant delete on samqa.bankserv_txn_staging to rl_sam_rw;

grant insert on samqa.bankserv_txn_staging to rl_sam_rw;

grant select on samqa.bankserv_txn_staging to rl_sam1_ro;

grant select on samqa.bankserv_txn_staging to rl_sam_rw;

grant select on samqa.bankserv_txn_staging to rl_sam_ro;

grant update on samqa.bankserv_txn_staging to rl_sam_rw;

