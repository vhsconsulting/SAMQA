-- liquibase formatted sql
-- changeset SAMQA:1754373925964 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbevent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbevent.sql:null:99a1d7da40ad51a464cb3a06c41c84b090082337:create

grant select on cobrap.qbevent to samqa;

