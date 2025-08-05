-- liquibase formatted sql
-- changeset SAMQA:1754374180210 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.asis_invoice_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.asis_invoice_dir.sql:null:c0f19e076d6e89ee1b8227eed6ee9fae328bae39:create

grant execute on directory sys.asis_invoice_dir to samqa;

grant read on directory sys.asis_invoice_dir to samqa;

grant write on directory sys.asis_invoice_dir to samqa;

