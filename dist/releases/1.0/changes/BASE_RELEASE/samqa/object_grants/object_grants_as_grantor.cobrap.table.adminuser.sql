-- liquibase formatted sql
-- changeset SAMQA:1754373925597 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.adminuser.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.adminuser.sql:null:43418ded49d76e0c63b5e9a3f7d8e006818f57de:create

grant select on cobrap.adminuser to samqa;

