-- liquibase formatted sql
-- changeset SAMQA:1754373926045 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmprojectedpremium.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmprojectedpremium.sql:null:4ab9bf832f28437e45ff8f8c7664bde65b21a086:create

grant select on cobrap.spmprojectedpremium to samqa;

