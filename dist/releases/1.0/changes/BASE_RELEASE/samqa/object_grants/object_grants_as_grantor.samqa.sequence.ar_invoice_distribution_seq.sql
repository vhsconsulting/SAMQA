-- liquibase formatted sql
-- changeset SAMQA:1754373937334 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ar_invoice_distribution_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ar_invoice_distribution_seq.sql:null:d0ac74b3ad10e9633dacffa5de8c902c6d747e07:create

grant select on samqa.ar_invoice_distribution_seq to rl_sam_rw;

