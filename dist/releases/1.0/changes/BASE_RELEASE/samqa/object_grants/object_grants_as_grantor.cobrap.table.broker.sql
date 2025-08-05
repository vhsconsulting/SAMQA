-- liquibase formatted sql
-- changeset SAMQA:1754373925614 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.broker.sql:null:eebba76017fef23d4b6a16b3b0a944c72cd05b5a:create

grant select on cobrap.broker to samqa;

