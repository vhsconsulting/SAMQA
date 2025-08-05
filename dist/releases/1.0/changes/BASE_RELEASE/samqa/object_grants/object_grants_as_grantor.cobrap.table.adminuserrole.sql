-- liquibase formatted sql
-- changeset SAMQA:1754373925602 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.adminuserrole.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.adminuserrole.sql:null:51347403f0981cd58de6a89b02a97e90d054c51e:create

grant select on cobrap.adminuserrole to samqa;

