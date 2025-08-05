-- liquibase formatted sql
-- changeset SAMQA:1754373925667 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientaccess.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientaccess.sql:null:7c4bc782b59aa538c26d418b69dae40073cb22a9:create

grant select on cobrap.clientaccess to samqa;

