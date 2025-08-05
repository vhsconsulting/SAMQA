-- liquibase formatted sql
-- changeset SAMQA:1754373925651 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.carriernote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.carriernote.sql:null:e35f9c004de9ec87ca9dd1ce3fe106d88e715e1f:create

grant select on cobrap.carriernote to samqa;

