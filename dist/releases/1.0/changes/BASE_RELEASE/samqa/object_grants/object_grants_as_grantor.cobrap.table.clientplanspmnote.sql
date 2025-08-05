-- liquibase formatted sql
-- changeset SAMQA:1754373925795 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientplanspmnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientplanspmnote.sql:null:076b798b613cfac22f5d2cb936bc2c510df49527:create

grant select on cobrap.clientplanspmnote to samqa;

