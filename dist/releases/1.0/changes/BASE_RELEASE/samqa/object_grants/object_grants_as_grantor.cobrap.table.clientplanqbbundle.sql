-- liquibase formatted sql
-- changeset SAMQA:1754373925761 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientplanqbbundle.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientplanqbbundle.sql:null:6bd7caf68fa9e3a78148fa1cc43ce09e0255dda3:create

grant select on cobrap.clientplanqbbundle to samqa;

