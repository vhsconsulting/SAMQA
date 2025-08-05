-- liquibase formatted sql
-- changeset SAMQA:1754373925635 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.carrier.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.carrier.sql:null:aaec74510b08169ee8938be7f4b52c5570de224f:create

grant select on cobrap.carrier to samqa;

