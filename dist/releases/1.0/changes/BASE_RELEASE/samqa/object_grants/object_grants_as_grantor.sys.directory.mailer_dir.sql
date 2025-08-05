-- liquibase formatted sql
-- changeset SAMQA:1754374180393 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.mailer_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.mailer_dir.sql:null:075be5ec63bd0fcec293273171259f12a5941772:create

grant execute on directory sys.mailer_dir to samqa;

grant read on directory sys.mailer_dir to samqa;

grant write on directory sys.mailer_dir to samqa;

