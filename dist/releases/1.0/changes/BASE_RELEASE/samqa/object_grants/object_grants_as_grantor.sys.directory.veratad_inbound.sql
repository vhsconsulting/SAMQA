-- liquibase formatted sql
-- changeset SAMQA:1754374180483 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.veratad_inbound.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.veratad_inbound.sql:null:07817c77c951252d29e519555e46880fa6b4c1ab:create

grant execute on directory sys.veratad_inbound to samqa;

grant read on directory sys.veratad_inbound to samqa;

grant write on directory sys.veratad_inbound to samqa;

