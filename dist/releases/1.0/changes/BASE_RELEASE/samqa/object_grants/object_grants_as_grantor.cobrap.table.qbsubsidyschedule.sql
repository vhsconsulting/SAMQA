-- liquibase formatted sql
-- changeset SAMQA:1754373925997 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbsubsidyschedule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbsubsidyschedule.sql:null:bd1997c1d2663bc757c30fe02e4c1d81e3f8706b:create

grant select on cobrap.qbsubsidyschedule to samqa;

