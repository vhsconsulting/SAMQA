-- liquibase formatted sql
-- changeset SAMQA:1754373926014 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmcommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmcommunication.sql:null:d53d2128c24284566f8fabb0e98c99e1fc29941e:create

grant select on cobrap.spmcommunication to samqa;

