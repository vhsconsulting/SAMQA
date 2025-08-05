-- liquibase formatted sql
-- changeset SAMQA:1754373937338 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ar_invoice_lines_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ar_invoice_lines_seq.sql:null:bb2142787c0536495b01c32413e9bb60c87c2781:create

grant select on samqa.ar_invoice_lines_seq to rl_sam_rw;

