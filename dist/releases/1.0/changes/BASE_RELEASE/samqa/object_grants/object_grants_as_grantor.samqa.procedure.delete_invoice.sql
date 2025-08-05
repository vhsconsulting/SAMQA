-- liquibase formatted sql
-- changeset SAMQA:1754373936825 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.delete_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.delete_invoice.sql:null:9446a2b15bed1e433e06c3eaa5deb1e73525ac0b:create

grant execute on samqa.delete_invoice to rl_sam_ro;

grant execute on samqa.delete_invoice to rl_sam_rw;

grant execute on samqa.delete_invoice to rl_sam1_ro;

grant debug on samqa.delete_invoice to rl_sam_rw;

grant debug on samqa.delete_invoice to rl_sam1_ro;

