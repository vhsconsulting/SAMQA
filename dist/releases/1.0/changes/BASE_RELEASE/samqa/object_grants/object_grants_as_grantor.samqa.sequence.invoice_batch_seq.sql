-- liquibase formatted sql
-- changeset SAMQA:1754373937849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.invoice_batch_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.invoice_batch_seq.sql:null:1ab835d1e080557223d4d7eb3282ce6953184923:create

grant select on samqa.invoice_batch_seq to rl_sam_rw;

