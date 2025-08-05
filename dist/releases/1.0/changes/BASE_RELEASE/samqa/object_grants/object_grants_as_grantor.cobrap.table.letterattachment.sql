-- liquibase formatted sql
-- changeset SAMQA:1754373925833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.letterattachment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.letterattachment.sql:null:432077adf57e39673ceb26c004fafcd6302576e8:create

grant select on cobrap.letterattachment to samqa;

