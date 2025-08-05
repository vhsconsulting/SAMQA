-- liquibase formatted sql
-- changeset SAMQA:1754374180325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.eob_out_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.eob_out_dir.sql:null:2b1fd93fdbf0d981c00fca84c43f1314a3266a34:create

grant execute on directory sys.eob_out_dir to samqa;

grant read on directory sys.eob_out_dir to samqa;

grant write on directory sys.eob_out_dir to samqa;

