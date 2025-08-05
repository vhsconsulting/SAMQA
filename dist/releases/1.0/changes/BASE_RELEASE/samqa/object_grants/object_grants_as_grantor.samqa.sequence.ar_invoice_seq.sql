-- liquibase formatted sql
-- changeset SAMQA:1754373937348 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ar_invoice_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ar_invoice_seq.sql:null:fb17b44630932bea465038bfb5560c5e5ab8fc82:create

grant select on samqa.ar_invoice_seq to rl_sam_rw;

