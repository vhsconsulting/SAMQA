-- liquibase formatted sql
-- changeset SAMQA:1754373925924 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qb.sql:null:505dbad09d1de266f5d8b30dc01b188f1e12a018:create

grant alter on cobrap.qb to samqa;

grant delete on cobrap.qb to samqa;

grant index on cobrap.qb to samqa;

grant insert on cobrap.qb to samqa;

grant select on cobrap.qb to samqa;

grant update on cobrap.qb to samqa;

grant references on cobrap.qb to samqa;

grant on commit refresh on cobrap.qb to samqa;

grant query rewrite on cobrap.qb to samqa;

grant debug on cobrap.qb to samqa;

grant flashback on cobrap.qb to samqa;

