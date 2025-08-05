-- liquibase formatted sql
-- changeset SAMQA:1754373925813 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientprocess.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientprocess.sql:null:7045356383bf71d8044e2c72cf10b65e4c9bce59:create

grant select on cobrap.clientprocess to samqa;

