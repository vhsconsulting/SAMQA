-- liquibase formatted sql
-- changeset SAMQA:1754373936971 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.migrate_pop_receipts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.migrate_pop_receipts.sql:null:305c22064c89074e499cd8486391583a06b33336:create

grant execute on samqa.migrate_pop_receipts to rl_sam_ro;

grant execute on samqa.migrate_pop_receipts to rl_sam_rw;

grant execute on samqa.migrate_pop_receipts to rl_sam1_ro;

grant debug on samqa.migrate_pop_receipts to sgali;

grant debug on samqa.migrate_pop_receipts to rl_sam_rw;

grant debug on samqa.migrate_pop_receipts to rl_sam1_ro;

