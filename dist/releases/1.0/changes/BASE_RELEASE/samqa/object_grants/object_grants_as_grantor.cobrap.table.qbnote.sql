-- liquibase formatted sql
-- changeset SAMQA:1754373925972 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbnote.sql:null:0c54732dd57609fb9e24a9c0aeea76572ae79966:create

grant select on cobrap.qbnote to samqa;

