-- liquibase formatted sql
-- changeset SAMQA:1754373925692 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientdivisionaccess.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientdivisionaccess.sql:null:eaa0796a1a601f9e9aa2dc535771fe3749b7eb33:create

grant select on cobrap.clientdivisionaccess to samqa;

