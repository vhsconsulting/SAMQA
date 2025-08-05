-- liquibase formatted sql
-- changeset SAMQA:1754374180240 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.benetrac_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.benetrac_dir.sql:null:4aad80388a18f5c05104e9313018c3c4db4885ee:create

grant execute on directory sys.benetrac_dir to samqa;

grant read on directory sys.benetrac_dir to samqa;

grant write on directory sys.benetrac_dir to samqa;

