-- liquibase formatted sql
-- changeset SAMQA:1754373925936 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbach.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbach.sql:null:64a2979b5d14c9e6886be9a2c29e17a4e403c8ff:create

grant select on cobrap.qbach to samqa;

