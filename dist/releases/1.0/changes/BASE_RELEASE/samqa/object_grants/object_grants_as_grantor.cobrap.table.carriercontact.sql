-- liquibase formatted sql
-- changeset SAMQA:1754373925646 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.carriercontact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.carriercontact.sql:null:234959d1da89fb3dd514195f242093b3f4f8b6d5:create

grant select on cobrap.carriercontact to samqa;

