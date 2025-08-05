-- liquibase formatted sql
-- changeset SAMQA:1754373925657 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.carriernotification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.carriernotification.sql:null:6eeed389f4da33ed173a7da8b24e3b0c56530879:create

grant select on cobrap.carriernotification to samqa;

