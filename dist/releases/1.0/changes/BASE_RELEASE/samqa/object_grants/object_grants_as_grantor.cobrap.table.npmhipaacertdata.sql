-- liquibase formatted sql
-- changeset SAMQA:1754373925897 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.npmhipaacertdata.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.npmhipaacertdata.sql:null:43a567a3fb783a05c4f0676d1ecc2941ea46bf40:create

grant select on cobrap.npmhipaacertdata to samqa;

