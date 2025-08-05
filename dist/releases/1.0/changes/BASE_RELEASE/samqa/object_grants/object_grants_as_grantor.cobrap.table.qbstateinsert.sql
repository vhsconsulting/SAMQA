-- liquibase formatted sql
-- changeset SAMQA:1754373925993 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbstateinsert.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbstateinsert.sql:null:c8dd3157ac0146dd2c20c14156eaf943d10d4b45:create

grant select on cobrap.qbstateinsert to samqa;

