-- liquibase formatted sql
-- changeset SAMQA:1754373925641 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.carrieraccess.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.carrieraccess.sql:null:7a92c4f59b2ca70e981cec4cf96043b5ea3aee24:create

grant select on cobrap.carrieraccess to samqa;

