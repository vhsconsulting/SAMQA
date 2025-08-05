-- liquibase formatted sql
-- changeset SAMQA:1754373925745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientgroup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientgroup.sql:null:6b8e3a43676dfead2e1ab27eb3196585dc17c1ac:create

grant select on cobrap.clientgroup to samqa;

