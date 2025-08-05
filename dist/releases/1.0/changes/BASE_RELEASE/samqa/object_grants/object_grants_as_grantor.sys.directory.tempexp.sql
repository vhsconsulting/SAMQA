-- liquibase formatted sql
-- changeset SAMQA:1754374180453 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.tempexp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.tempexp.sql:null:c7647ad53046ad521d3268bacacab7f5d314e0e5:create

grant execute on directory sys.tempexp to samqa;

grant read on directory sys.tempexp to samqa;

grant write on directory sys.tempexp to samqa;

