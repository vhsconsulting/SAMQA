-- liquibase formatted sql
-- changeset SAMQA:1754373926005 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmaccess.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmaccess.sql:null:542bd302d76e3ddb08e3251774e04d42ccda36f8:create

grant select on cobrap.spmaccess to samqa;

