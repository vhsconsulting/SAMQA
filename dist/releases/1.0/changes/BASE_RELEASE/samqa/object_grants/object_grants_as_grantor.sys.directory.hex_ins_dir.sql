-- liquibase formatted sql
-- changeset SAMQA:1754374180362 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.hex_ins_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.hex_ins_dir.sql:null:b79cae654a4706267e5fff775cf446163b143713:create

grant execute on directory sys.hex_ins_dir to samqa;

grant read on directory sys.hex_ins_dir to samqa;

grant write on directory sys.hex_ins_dir to samqa;

