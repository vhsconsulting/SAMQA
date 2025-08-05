-- liquibase formatted sql
-- changeset SAMQA:1754373925826 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.customer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.customer.sql:null:7dff41406d9b2b21cde486d1f53f1f85ab8e96be:create

grant select on cobrap.customer to samqa;

