-- liquibase formatted sql
-- changeset SAMQA:1754373926027 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmnote.sql:null:b53d155d7e291bd810015c3722b92d42d8f89c51:create

grant select on cobrap.spmnote to samqa;

