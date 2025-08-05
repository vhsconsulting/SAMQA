-- liquibase formatted sql
-- changeset SAMQA:1754373925590 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.adminrole.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.adminrole.sql:null:7fc70d15d5b0b74b8e95aa05a01f428a438fbe84:create

grant select on cobrap.adminrole to samqa;

