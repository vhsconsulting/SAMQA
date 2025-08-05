-- liquibase formatted sql
-- changeset SAMQA:1754373926036 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmplan.sql:null:631b751cbb33ced170fd1c32919f4d31b78f3a39:create

grant select on cobrap.spmplan to samqa;

