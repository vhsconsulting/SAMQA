-- liquibase formatted sql
-- changeset SAMQA:1754373925861 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.memberpaymenttotal.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.memberpaymenttotal.sql:null:0fd6660dd9747b2aa4f1986cf3630a79429e4585:create

grant select on cobrap.memberpaymenttotal to samqa;

