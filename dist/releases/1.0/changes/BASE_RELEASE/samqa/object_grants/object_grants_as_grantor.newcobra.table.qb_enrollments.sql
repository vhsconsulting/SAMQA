-- liquibase formatted sql
-- changeset SAMQA:1754373926350 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.qb_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.qb_enrollments.sql:null:7f257a7958278843f2d443bdb520261d878b5fa8:create

grant alter on newcobra.qb_enrollments to samqa;

grant delete on newcobra.qb_enrollments to samqa;

grant index on newcobra.qb_enrollments to samqa;

grant insert on newcobra.qb_enrollments to samqa;

grant select on newcobra.qb_enrollments to samqa;

grant update on newcobra.qb_enrollments to samqa;

grant references on newcobra.qb_enrollments to samqa;

grant read on newcobra.qb_enrollments to samqa;

grant on commit refresh on newcobra.qb_enrollments to samqa;

grant query rewrite on newcobra.qb_enrollments to samqa;

grant debug on newcobra.qb_enrollments to samqa;

grant flashback on newcobra.qb_enrollments to samqa;

