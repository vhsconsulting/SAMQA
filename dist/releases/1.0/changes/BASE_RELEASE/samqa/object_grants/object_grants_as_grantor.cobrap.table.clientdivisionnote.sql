-- liquibase formatted sql
-- changeset SAMQA:1754373925708 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientdivisionnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientdivisionnote.sql:null:c783094d9769f20d895dbe61b99198b1b3bf4488:create

grant select on cobrap.clientdivisionnote to samqa;

