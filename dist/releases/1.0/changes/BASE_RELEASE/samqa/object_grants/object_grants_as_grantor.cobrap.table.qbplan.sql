-- liquibase formatted sql
-- changeset SAMQA:1754373925980 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbplan.sql:null:f39cb6bf7a7c45e5b0c90b2d22f2c5b5b7687a34:create

grant select on cobrap.qbplan to samqa;

