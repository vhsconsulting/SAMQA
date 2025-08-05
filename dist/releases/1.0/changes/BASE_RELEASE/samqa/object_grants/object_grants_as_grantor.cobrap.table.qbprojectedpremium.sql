-- liquibase formatted sql
-- changeset SAMQA:1754373925989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbprojectedpremium.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbprojectedpremium.sql:null:91167949f3beffb45f82e72ce0a84642b430ea59:create

grant select on cobrap.qbprojectedpremium to samqa;

