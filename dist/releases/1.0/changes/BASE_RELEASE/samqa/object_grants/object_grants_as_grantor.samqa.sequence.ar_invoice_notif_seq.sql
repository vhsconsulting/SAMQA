-- liquibase formatted sql
-- changeset SAMQA:1754373937343 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ar_invoice_notif_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ar_invoice_notif_seq.sql:null:e4e2a3af7c8328b295bf850779917717d92301a2:create

grant select on samqa.ar_invoice_notif_seq to rl_sam_rw;

