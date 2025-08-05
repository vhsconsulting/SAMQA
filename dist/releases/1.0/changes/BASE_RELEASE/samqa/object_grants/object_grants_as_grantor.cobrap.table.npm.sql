-- liquibase formatted sql
-- changeset SAMQA:1754373925877 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.npm.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.npm.sql:null:60f7c4ec9b9269b88f9517acac294556713e0005:create

grant select on cobrap.npm to samqa;

