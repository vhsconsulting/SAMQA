-- liquibase formatted sql
-- changeset SAMQA:1754373926018 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmdependent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmdependent.sql:null:330e15cb94de1f20b6f9ad187575e4a032256bd2:create

grant select on cobrap.spmdependent to samqa;

