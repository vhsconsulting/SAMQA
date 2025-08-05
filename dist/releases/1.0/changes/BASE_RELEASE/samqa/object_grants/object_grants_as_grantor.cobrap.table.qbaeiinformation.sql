-- liquibase formatted sql
-- changeset SAMQA:1754373925941 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbaeiinformation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbaeiinformation.sql:null:054e4ab31b902d62344ad5a630632b84ce2a735b:create

grant select on cobrap.qbaeiinformation to samqa;

