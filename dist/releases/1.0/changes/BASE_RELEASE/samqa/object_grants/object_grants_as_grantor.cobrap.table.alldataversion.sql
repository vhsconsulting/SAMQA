-- liquibase formatted sql
-- changeset SAMQA:1754373925608 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.alldataversion.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.alldataversion.sql:null:1315b42eca453fb105ad86d6177a3254e701cfef:create

grant select on cobrap.alldataversion to samqa;

