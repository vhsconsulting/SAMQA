-- liquibase formatted sql
-- changeset SAMQA:1754373937865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.invoice_number_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.invoice_number_seq.sql:null:6c71588b3b314ae2cd7859ee4882bd1406e37dd6:create

grant select on samqa.invoice_number_seq to rl_sam_rw;

