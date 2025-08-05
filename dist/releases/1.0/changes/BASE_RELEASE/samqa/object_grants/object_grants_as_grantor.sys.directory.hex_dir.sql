-- liquibase formatted sql
-- changeset SAMQA:1754374180356 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.hex_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.hex_dir.sql:null:453886c730cf9ed02a35426637755e43630c2654:create

grant execute on directory sys.hex_dir to samqa;

grant read on directory sys.hex_dir to samqa;

grant write on directory sys.hex_dir to samqa;

