-- liquibase formatted sql
-- changeset SAMQA:1754373937098 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.reprocess_card_settlement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.reprocess_card_settlement.sql:null:bde317ab5bcc4715708d967d230e4e975607ad80:create

grant execute on samqa.reprocess_card_settlement to rl_sam_ro;

grant execute on samqa.reprocess_card_settlement to rl_sam1_ro;

grant execute on samqa.reprocess_card_settlement to rl_sam_rw;

grant debug on samqa.reprocess_card_settlement to rl_sam1_ro;

grant debug on samqa.reprocess_card_settlement to rl_sam_rw;

