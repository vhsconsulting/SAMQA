-- liquibase formatted sql
-- changeset SAMQA:1754373936265 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_invoice_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_invoice_reports.sql:null:af10d582f6ce038c8c1ef65eec59c796722c5978:create

grant execute on samqa.pc_invoice_reports to rl_sam_rw;

grant execute on samqa.pc_invoice_reports to rl_sam1_ro;

grant execute on samqa.pc_invoice_reports to rl_sam_ro;

grant debug on samqa.pc_invoice_reports to rl_sam_rw;

grant debug on samqa.pc_invoice_reports to rl_sam1_ro;

grant debug on samqa.pc_invoice_reports to rl_sam_ro;

