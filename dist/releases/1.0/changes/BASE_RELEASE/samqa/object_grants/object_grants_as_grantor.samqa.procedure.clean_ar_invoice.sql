-- liquibase formatted sql
-- changeset SAMQA:1754373936709 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.clean_ar_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.clean_ar_invoice.sql:null:fd0a34e92e6eefcae39f5e70c1fbf3f0b5d97e02:create

grant execute on samqa.clean_ar_invoice to rl_sam_ro;

grant execute on samqa.clean_ar_invoice to rl_sam_rw;

grant execute on samqa.clean_ar_invoice to rl_sam1_ro;

grant debug on samqa.clean_ar_invoice to rl_sam_rw;

grant debug on samqa.clean_ar_invoice to rl_sam1_ro;

