-- liquibase formatted sql
-- changeset SAMQA:1754373925751 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientnote.sql:null:652374efafd53673da0472ace94893a01a980280:create

grant select on cobrap.clientnote to samqa;

