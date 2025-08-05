-- liquibase formatted sql
-- changeset SAMQA:1754373925685 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientdivision.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientdivision.sql:null:ca48ecb61af03a06390ffb5bda5890c0e698128c:create

grant select on cobrap.clientdivision to samqa;

