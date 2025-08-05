-- liquibase formatted sql
-- changeset SAMQA:1754373926309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.plan_elections.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.plan_elections.sql:null:bb2ae36728240f65cd9fee023139516972fadda5:create

grant alter on newcobra.plan_elections to samqa;

grant delete on newcobra.plan_elections to samqa;

grant index on newcobra.plan_elections to samqa;

grant insert on newcobra.plan_elections to samqa;

grant select on newcobra.plan_elections to samqa;

grant update on newcobra.plan_elections to samqa;

grant references on newcobra.plan_elections to samqa;

grant read on newcobra.plan_elections to samqa;

grant on commit refresh on newcobra.plan_elections to samqa;

grant query rewrite on newcobra.plan_elections to samqa;

grant debug on newcobra.plan_elections to samqa;

grant flashback on newcobra.plan_elections to samqa;

