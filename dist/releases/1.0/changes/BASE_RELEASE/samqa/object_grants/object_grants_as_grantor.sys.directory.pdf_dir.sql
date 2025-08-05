-- liquibase formatted sql
-- changeset SAMQA:1754374180411 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.pdf_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.pdf_dir.sql:null:d38533b9d61677d2c75dc7e112a19b821c5648fa:create

grant execute on directory sys.pdf_dir to samqa;

grant read on directory sys.pdf_dir to samqa;

grant write on directory sys.pdf_dir to samqa;

