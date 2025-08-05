-- liquibase formatted sql
-- changeset SAMQA:1754373925739 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientfee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientfee.sql:null:c747f4cd3219e24d0ae6600c806c85cc4492ee54:create

grant select on cobrap.clientfee to samqa;

