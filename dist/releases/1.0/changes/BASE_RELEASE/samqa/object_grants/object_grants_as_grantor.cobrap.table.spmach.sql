-- liquibase formatted sql
-- changeset SAMQA:1754373926009 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmach.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmach.sql:null:4331f06532bea6ea9e80a4fb519683b965cc3c9d:create

grant select on cobrap.spmach to samqa;

