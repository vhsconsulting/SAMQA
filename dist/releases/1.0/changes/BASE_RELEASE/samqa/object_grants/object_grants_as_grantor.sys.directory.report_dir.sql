-- liquibase formatted sql
-- changeset SAMQA:1754374180417 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.report_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.report_dir.sql:null:600c8c9280a979c2324b8e75e77f1f49c7b16024:create

grant execute on directory sys.report_dir to samqa;

grant read on directory sys.report_dir to samqa;

grant write on directory sys.report_dir to samqa;

