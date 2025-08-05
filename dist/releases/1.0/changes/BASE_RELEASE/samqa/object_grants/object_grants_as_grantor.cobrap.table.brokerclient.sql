-- liquibase formatted sql
-- changeset SAMQA:1754373925619 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.brokerclient.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.brokerclient.sql:null:a665b2e30b87b98c42e48a6c1a5c186eb41e5bf9:create

grant select on cobrap.brokerclient to samqa;

