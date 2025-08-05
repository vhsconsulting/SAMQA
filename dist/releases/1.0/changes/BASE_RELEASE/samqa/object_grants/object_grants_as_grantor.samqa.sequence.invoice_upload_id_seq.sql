-- liquibase formatted sql
-- changeset SAMQA:1754373937881 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.invoice_upload_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.invoice_upload_id_seq.sql:null:3083d8dc82b36d7d48de63923941f0666b34d6e0:create

grant select on samqa.invoice_upload_id_seq to rl_sam_rw;

