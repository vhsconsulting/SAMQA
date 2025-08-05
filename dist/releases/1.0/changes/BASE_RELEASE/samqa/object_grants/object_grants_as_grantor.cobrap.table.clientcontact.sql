-- liquibase formatted sql
-- changeset SAMQA:1754373925680 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientcontact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientcontact.sql:null:23a7facf5ec58b27a665e67d3ba6e1a828798343:create

grant select on cobrap.clientcontact to samqa;

