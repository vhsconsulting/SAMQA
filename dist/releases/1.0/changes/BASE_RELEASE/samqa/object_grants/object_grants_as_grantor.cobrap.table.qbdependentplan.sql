-- liquibase formatted sql
-- changeset SAMQA:1754373925956 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbdependentplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbdependentplan.sql:null:a8e8a30f3153d6cfec7cab5e5991d8bfa124a725:create

grant select on cobrap.qbdependentplan to samqa;

