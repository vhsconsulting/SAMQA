-- liquibase formatted sql
-- changeset SAMQA:1754373925890 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.npmcommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.npmcommunication.sql:null:2a2cfa722ef0fad81321512f013ccca9696ac0e4:create

grant select on cobrap.npmcommunication to samqa;

