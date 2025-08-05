-- liquibase formatted sql
-- changeset SAMQA:1754374180301 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.edi_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.edi_dir.sql:null:b3ecab73a80edf911bbf19d209415a9fe5b7aee0:create

grant execute on directory sys.edi_dir to samqa;

grant read on directory sys.edi_dir to samqa;

grant write on directory sys.edi_dir to samqa;

