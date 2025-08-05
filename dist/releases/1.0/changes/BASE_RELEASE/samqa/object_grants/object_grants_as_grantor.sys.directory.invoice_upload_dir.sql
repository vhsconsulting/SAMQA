-- liquibase formatted sql
-- changeset SAMQA:1754374180381 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.invoice_upload_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.invoice_upload_dir.sql:null:1aac33d9ee9347dafac8f964544e6dc957b5f0b9:create

grant execute on directory sys.invoice_upload_dir to samqa;

grant read on directory sys.invoice_upload_dir to samqa;

grant write on directory sys.invoice_upload_dir to samqa;

