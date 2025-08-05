-- liquibase formatted sql
-- changeset SAMQA:1754373926031 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmpayment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmpayment.sql:null:af3e96f983f3d3e2ea4b8a2134b2db90e224bf7b:create

grant select on cobrap.spmpayment to samqa;

