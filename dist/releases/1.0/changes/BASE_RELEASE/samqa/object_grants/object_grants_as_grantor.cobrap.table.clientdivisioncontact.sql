-- liquibase formatted sql
-- changeset SAMQA:1754373925702 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientdivisioncontact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientdivisioncontact.sql:null:1878a8df571636ed27218bc6acf0b010904ff562:create

grant select on cobrap.clientdivisioncontact to samqa;

