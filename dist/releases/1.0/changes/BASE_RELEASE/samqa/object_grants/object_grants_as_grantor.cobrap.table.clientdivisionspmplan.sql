-- liquibase formatted sql
-- changeset SAMQA:1754373925726 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientdivisionspmplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientdivisionspmplan.sql:null:a005070bf456ab0a4d792cf01085eff2543c56ed:create

grant select on cobrap.clientdivisionspmplan to samqa;

