-- liquibase formatted sql
-- changeset SAMQA:1754373925756 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientplanqb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientplanqb.sql:null:5fda4604c17716484ef9298d92a4099be0a356e7:create

grant select on cobrap.clientplanqb to samqa;

