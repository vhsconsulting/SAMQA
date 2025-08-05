-- liquibase formatted sql
-- changeset SAMQA:1754373925952 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbdependent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbdependent.sql:null:0bee205ece88012335fa544028c0e153a4dfc5e1:create

grant select on cobrap.qbdependent to samqa;

