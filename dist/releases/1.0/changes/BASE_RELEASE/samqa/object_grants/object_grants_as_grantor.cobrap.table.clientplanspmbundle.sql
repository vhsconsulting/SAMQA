-- liquibase formatted sql
-- changeset SAMQA:1754373925789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientplanspmbundle.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientplanspmbundle.sql:null:048cedfd4b143d54be162550bd9da7fef54637e4:create

grant select on cobrap.clientplanspmbundle to samqa;

