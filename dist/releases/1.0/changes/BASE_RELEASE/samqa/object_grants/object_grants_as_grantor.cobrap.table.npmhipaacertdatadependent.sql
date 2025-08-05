-- liquibase formatted sql
-- changeset SAMQA:1754373925905 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.npmhipaacertdatadependent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.npmhipaacertdatadependent.sql:null:4e9bc28e6415dde4256a761f9bcbf8b551764577:create

grant select on cobrap.npmhipaacertdatadependent to samqa;

