-- liquibase formatted sql
-- changeset SAMQA:1754373925910 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.npmnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.npmnote.sql:null:3455125d4af46b102f4d984b86aafb5d6092624d:create

grant select on cobrap.npmnote to samqa;

