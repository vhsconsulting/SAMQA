-- liquibase formatted sql
-- changeset SAMQA:1754373925805 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientplanspmrate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientplanspmrate.sql:null:1a8f76981ffb8a44a9e3322e3e77fdb110153f4a:create

grant select on cobrap.clientplanspmrate to samqa;

