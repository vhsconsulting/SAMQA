-- liquibase formatted sql
-- changeset SAMQA:1754373925673 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientcommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientcommunication.sql:null:7606fd0c2cb6cec6bc8a32ce4ac4784c3bc755c6:create

grant select on cobrap.clientcommunication to samqa;

