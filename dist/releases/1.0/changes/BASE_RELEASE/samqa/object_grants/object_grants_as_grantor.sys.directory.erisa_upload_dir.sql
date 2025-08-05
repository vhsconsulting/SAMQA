-- liquibase formatted sql
-- changeset SAMQA:1754374180331 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.erisa_upload_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.erisa_upload_dir.sql:null:d199dd47ade859316dc479ea51505f35adc1fcb4:create

grant execute on directory sys.erisa_upload_dir to samqa;

grant read on directory sys.erisa_upload_dir to samqa;

grant write on directory sys.erisa_upload_dir to samqa;

