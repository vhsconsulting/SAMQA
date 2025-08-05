-- liquibase formatted sql
-- changeset SAMQA:1754373925698 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientdivisioncommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientdivisioncommunication.sql:null:7dcc755580e70fdc75dd4443aff0b2739ae68f68:create

grant select on cobrap.clientdivisioncommunication to samqa;

