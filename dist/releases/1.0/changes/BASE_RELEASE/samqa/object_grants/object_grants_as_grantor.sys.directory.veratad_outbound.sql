-- liquibase formatted sql
-- changeset SAMQA:1754374180489 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.veratad_outbound.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.veratad_outbound.sql:null:2417e7457e8420ef5608523c3d5da20bcc2561f9:create

grant execute on directory sys.veratad_outbound to samqa;

grant read on directory sys.veratad_outbound to samqa;

grant write on directory sys.veratad_outbound to samqa;

