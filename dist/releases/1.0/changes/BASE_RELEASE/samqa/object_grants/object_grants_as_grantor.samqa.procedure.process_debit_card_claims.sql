-- liquibase formatted sql
-- changeset SAMQA:1754373937006 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.process_debit_card_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.process_debit_card_claims.sql:null:c62c7f433db5a9a5062905d5e8c999fb45bafe84:create

grant execute on samqa.process_debit_card_claims to rl_sam_ro;

grant execute on samqa.process_debit_card_claims to rl_sam_rw;

grant execute on samqa.process_debit_card_claims to rl_sam1_ro;

grant debug on samqa.process_debit_card_claims to sgali;

grant debug on samqa.process_debit_card_claims to rl_sam_rw;

grant debug on samqa.process_debit_card_claims to rl_sam1_ro;

