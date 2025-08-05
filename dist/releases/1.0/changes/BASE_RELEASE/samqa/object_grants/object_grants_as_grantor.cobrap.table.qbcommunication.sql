-- liquibase formatted sql
-- changeset SAMQA:1754373925947 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbcommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbcommunication.sql:null:804c742ae6c1a2137681dddd1de828dea6b69b22:create

grant select on cobrap.qbcommunication to samqa;

