-- liquibase formatted sql
-- changeset SAMQA:1754373926338 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.plan_members.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.plan_members.sql:null:d781eadfada933c440e3a955b2cd81da2971faaf:create

grant alter on newcobra.plan_members to samqa;

grant delete on newcobra.plan_members to samqa;

grant index on newcobra.plan_members to samqa;

grant insert on newcobra.plan_members to samqa;

grant select on newcobra.plan_members to samqa;

grant update on newcobra.plan_members to samqa;

grant references on newcobra.plan_members to samqa;

grant read on newcobra.plan_members to samqa;

grant on commit refresh on newcobra.plan_members to samqa;

grant query rewrite on newcobra.plan_members to samqa;

grant debug on newcobra.plan_members to samqa;

grant flashback on newcobra.plan_members to samqa;

