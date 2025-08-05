-- liquibase formatted sql
-- changeset SAMQA:1754373925714 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientdivisionqbplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientdivisionqbplan.sql:null:bb48f2fe1734f637f05af1aa2504a2655690212d:create

grant select on cobrap.clientdivisionqbplan to samqa;

