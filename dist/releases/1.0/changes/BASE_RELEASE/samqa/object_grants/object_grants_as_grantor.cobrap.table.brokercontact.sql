-- liquibase formatted sql
-- changeset SAMQA:1754373925625 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.brokercontact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.brokercontact.sql:null:c22012c73c30f8405fba7784f0278225d39e4997:create

grant select on cobrap.brokercontact to samqa;

